---
layout: post
title:  VMware Automation
date:   2012-12-09 21:45:00
categories: vmware
---

I recently had the opportunity to spend some time automating VMware for a client. This post focuses on the <a href="http://www.vmware.com/support/developer/viperltoolkit/">vSphere SDK for Perl</a> and modern Linux guests (e.g. RHEL6). VMware's own documentation is pretty good, documenting every method of the SDK, but overall, I found it clunky to use.  Also, with the SDK being distributed as a monolithic tarball, you're left to install this yourself, using CPAN manually to resolve a number of dependencies.

Once you have the VMware SDK installed following the instructions included in the tarball, you have a few options.

You can write your own scripts quite easily using the Perl SDK's hundreds of available methods, but this is out of scope for this post.  VMware helpfully includes several example tools already that (mostly) work just fine in /usr/lib/vmware-cli/apps/.

<h2>Authentication Options</h2>

All of the VMware Perl utilities can use either --username, --password, and --server options, but you can also store the credentials in your home directory, in $HOME/.visdkrc:

{% highlight bash %}
VI_SERVER = vcenter.bitbin.de
VI_USERNAME = bitbin\stephen
VI_PASSWORD = Sup3rS3CR3T!
VI_PROTOCOL = https
VI_PORTNUMBER = 443
{% endhighlight %}

For the rest of this post, I'll omit the username, password, and server settings. Assume them if you're not using stored credentials.

<h2>Creating a VM</h2>

vmcreate.pl does exactly what you'd imagine -- it creates a VM.  The Syntax is simple:

{% highlight bash %}
# ./vmcreate.pl --filename=yourvm.xml \
--schema=/usr/lib/vmware-vcli/apps/schema/vmcreate.xsd
{% endhighlight %}

yourvm.xml should look like the XML below, with appropriate values for each item. VMware provides examples <a href="http://www.vmware.com/support/developer/viperltoolkit/doc/utilityappsdoc/vmcreate.html">here</a>.

{% highlight xml %}
<?xml version="1.0"?>
<Virtual-Machines>
  <Virtual-Machine>
    <Name>$HOSTNAME</Name>
    <Host>$HYPERVISOR</Host>
    <Datacenter>$DATACENTER</Datacenter>
    <Guest-Id>$GUESTID</Guest-Id>
    <Datastore>$DATASTORE</Datastore>
    <Disksize>$DISKSIZE</Disksize>
    <Memory>$MEMORY</Memory>
    <Number-of-Processor>$CPU</Number-of-Processor>
    <Nic-Network>$NETWORK</Nic-Network>
    <Nic-Poweron>0</Nic-Poweron>
  </Virtual-Machine>
</Virtual-Machines>
{% endhighlight %}

However, there's one key caveat to all this: the default settings for vmcreate.pl
are in the case of the network adapter not optimized, and in the case of the default
SCSI bus <strong>incompatible</strong> with RHEL6 (and CentOS6, and probably any verison of Fedora).

I have created a patch file that fixes these things:
<ul>
    <li>Storage controller is updated to Paravirtual</li>
    <li>Network adapter is updated to VMXNET3</li>
    <li>Default provisioning is added to be "thin"</li>
</ul>

{% highlight dpatch %}
 — /tmp/vmcreate.pl 2012-12-03 13:16:50.515627368 +0000
+++ vmcreate.pl 2012-12-04 08:17:19.710563460 +0000
@@ -219,7 +219,7 @@
# ================================================
sub create_conf_spec {
my $controller =
– VirtualBusLogicController->new(key => 0,
+ ParaVirtualSCSIController->new(key => 0,
device => [0],
busNumber => 0,
sharedBus => VirtualSCSISharing->new(‘noSharing’));
@@ -240,7 +240,8 @@

my $disk_backing_info =
VirtualDiskFlatVer2BackingInfo->new(diskMode => ‘persistent’,
– fileName => $ds_path);
+ fileName => $ds_path,
+ thinProvisioned => 1);

my $disk = VirtualDisk->new(backing => $disk_backing_info,
controllerKey => 0,
@@ -280,7 +281,7 @@
connected => 0,
startConnected => $poweron);

– my $nic = VirtualPCNet32->new(backing => $nic_backing_info,
+ my $nic = VirtualVmxnet3->new(backing => $nic_backing_info,
key => 0,
unitNumber => $unit_num,
addressType => ‘generated’,
{% endhighlight %}

<h2>Where's the MAC Address?</h2>

Now at this point, you might be asking yourself, where's the MAC address?  I left vmcreate.pl to it's default action, which is let VMware auto-generate it.  However, I still needed to fetch it back after the VM was created, so that I could create the profile in Cobbler for automatic installation.

There's no real easy way with the utilities, the only way I found was file scraping.

<strong>fileaccess.pl </strong>is a utility that allows you to download files from VMware, including the .vmx file which contains the auto-generated MAC address.  Replace DATACENTEr, DATASTORE, and VMNAME with the appropriate fields.

{% highlight bash %}
./fileaccess.pl --datacenter=DATACENTER \
--datastorename=DATASTORE --filetype=datastore \
--remotepath=VMNNAME/VMNAME.vmx --localpath=/tmp/mac.txt \
--operation=get
{% endhighlight %}

You'll need the "ethernet0.generatedAddress" field from this file.

<h2>Booting Your New VM</h2>
You can control the state of your VM's with <strong>vmcontrol.pl</strong>:

{% highlight bash %}
./vmcontrol.pl --datacenter=DATACENTER \
--vmname=VMNAME --operation=poweron
{% endhighlight %}

You can also change the operation to 'poweroff.'

Update: A colleague pointed me to the idea that working with J<a href="http://vijava.sourceforge.net/files/Scripting%20VI%20SDK%20with%20Jython.pdf">ython and the Java VI SDK</a> might be a good idea for more complicated use cases.  I tested it a little, and it works pretty well.
