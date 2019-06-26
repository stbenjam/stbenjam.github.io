---
layout: post
title: UEFI HTTP Boot with Libvirt
date: 2019-04-29 7:35:00
categories: technical
comments: true
---

In UEFI 2.5, HTTP boot was introduced.  This feature allows a UEFI host
to network boot using HTTP instead of TFTP.  If you enroll a trusted
certificate authority on the server, then you can boot securely using
HTTPS. This is a vast improvement over older mechanisms that make use
of insecure protocols like TFTP.

Lukáš from the Foreman project [proposed an
RFC](https://community.theforeman.org/t/rfc-uefi-http-booting/8723/12)
to enable this functionality in Foreman. Much of this is now
implemented: Foreman has an HTTPBoot Smart Proxy module that serves the
TFTP boot directory via HTTP, and makes Foreman aware of various DHCP
settings.  There are still [some
issues](https://projects.theforeman.org/issues/26337) to be resolved
before this is ready for users to use.

This blog post is mostly my notes from us researching how HTTP boot
works, how grub2 supports HTTP boot, and how to test with libvirt.
We used the edk2 firmware for QEMU/KVM, although much of these notes are
generally applicable to hardware as well - we've tested on at least one
real world baremetal server and was able to provision end-to-end using
HTTPS.

## Configure libvirt

Out of the box, QEMU will use BIOS. However, you can install the
Tianocore firmware to get UEFI.  This package is called `edk2-ovmf` on
Fedora.

If you are on CentOS 7 or want to use the latest nightlies, you can get
them from [this fedora
documentation](https://fedoraproject.org/wiki/Using_UEFI_with_QEMU#Installing_.27UEFI_for_QEMU.27_nightly_builds.).
Last I checked, they don't have TLS support compiled, which means you
can't enroll a TLS certificate to make HTTPS boot work. The Fedora
firmware *does* support this.

After installing the firmware package on CentOS, you'll also need to
configure the nvram setting in `/etc/libvirt/qemu.conf`.  Newer Fedoras
are already aware of and will look in this path for firmwares:

```
nvram = [
  "/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd:/usr/share/edk2.git/ovmf-x64/OVMF_VARS-pure-efi.fd"
]
```

Once you do that, you can create an UEFI VM, by selecting a UEFI x86_64 firmware:

![UEFI Firmware Selection in Virt-Manager](/images/2018/uefi.png)

## Configure DHCP

Your DHCP configuration must be aware of HTTP clients in order to
set the filename to an URL. The relevant snippet from my own DHCP config
is below.  It's important to set the `vendor-class-identifier` as
HTTPClient, otherwise your host will not use the filename as an HTTP
URL.

```
option arch code 93 = unsigned integer 16; # RFC4578

# This is for UEFI HTTP:
class "httpclients" {
  match if substring (option vendor-class-identifier, 0, 10) = "HTTPClient";
  log(info, "HTTP UEFI Client Detected");
  option vendor-class-identifier "HTTPClient";

  if option arch = 00:0F {
    filename "http://example.com/bootia32.efi";
  } else if option arch = 00:10 {
    filename "http://example.com/bootx64.efi";
  }
}
```

## Boot loader

I've tested HTTP boot with both iPXE and grub2. If iPXE supports your
network card, you might consider using it. It supports [UEFI HTTP
Boot](https://ipxe.org/appnote/uefihttp) well.

If you want to use grub2, hang on to your hat - there's a number of bugs
in any of the latest shipped versions, including in Fedora 30. Fixes
that enable using relative paths will ship in Fedora 31. The bug for
that is [here](https://bugzilla.redhat.com/show_bug.cgi?id=1616395).

If your grub2 configuration uses fully qualified paths in all places,
you won't need this patch, but you won't be able to use your grub2
configuration for both legacy TFTP and HTTP clients.

## Enrolling a CA Certificate

For libvirt, I created a VFAT image, and stored a copy of my CA
certificate there:

```
$ dd if=/dev/zero of=/tmp/ca.img bs=1440K count=1
1+0 records in
1+0 records out
1474560 bytes (1.5 MB, 1.4 MiB) copied, 0.000856816 s, 1.7 GB/s
$ mkfs.vfat /tmp/ca.img
mkfs.fat 4.1 (2017-01-24)
$ sudo mount -o loop /tmp/ca.img /tmp/mnt
$ sudo cp /tmp/ca/ca.crt /tmp/mnt
$ sudo umount /tmp/mnt
$ sudo cp /tmp/ca.img /var/lib/libvirt/images
```

I then attached it to libvirt:

![Floppy](/images/2018/floppy.png)

and enrolled the certificate in the Device Manager menu:

![Enrollment](/images/2018/enroll.gif)

Assuming your DHCP configuration is setup correctly, then you can select
HTTP boot from the Boot Manager, or reboot the host, and you will boot
via HTTPS.
