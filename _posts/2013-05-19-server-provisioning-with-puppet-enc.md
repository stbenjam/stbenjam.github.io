---
layout: post
title:  Server Provisioning with Puppet ENC
date:   2013-05-19 21:08:00
categories: puppet technical
---

The Puppet<a href="http://docs.puppetlabs.com/guides/external_nodes.html"> External Node Classifier </a>(ENC) is extremely useful for configuring systems based on data in an external source like a CMDB.   It is really the killer feature of Puppet, IMHO.  Essentially, the ENC is any arbitrary script that Puppet calls to find out which classes and parameters a system should have.  The output it expects is in a human-readable serialized data format known as YAML.

One of the key ideas I try to communicate to my consulting customers is the importance of having "<strong>one source of truth</strong>."  It's harder than you think with many organizations relying on a number of different databases for information about their systems -- or having none of this data tracked at all.  It's rare I find a customer who has just one well-organized source.  That being said,  I believe the ENC is a good starting point for this one source of truth, because the serialized data that puppet uses can contain other arbitrary information, and used in other automation projects -- such as your provisioning layer.

<a href="/static/images/2013/05/ENC.png"><img class="aligncenter size-full wp-image-511" alt="ENC" src="/static/images/2013/05/ENC.png" width="653" height="441" /></a>

Ultimately, the backend doesn't matter too much.  I've used various different approaches depending on the maturity level of the customer.  Sometimes I need to pull the data from  more than one source (for example, IP info from an IPAM, and the rest from another source), but once the integration is done, you're left with at least a single entry point for any of your automation. Projects like <a href="http://theforeman.org/">the Foreman</a> are rapidly maturing to really replace the need to manually glue these things all together, but rolling your own is a good solution to start from.

Once the ENC script is written, you now need consumers of this information.  One of the first things you might like to do is actually start building these systems.

My solution for this is the  cobbler-puppet ENC consumer, available on my github here: <a href="https://github.com/stbenjam/cobbler-puppet">https://github.com/stbenjam/cobbler-puppet</a>.  It's a fully functional piece of software with RPM spec files.  Once you have an ENC, and a Cobbler infrastructure, you can link the two quite easily.

By default the script expects ENC output like this:

{% highlight yaml %}
---
classes:
  foo:
  bar:
  baz:
parameters:
  cobbler_system_name: www1
  cobbler_hostname: www1.example.com
  cobbler_profile: default
  cobbler_kernel_opts:
    quiet:
    acpi: off
  cobbler_kernel_opts_post:
    quiet:
    acpi: on
  cobbler_ks_meta:
    potato: true
  cobbler_name_servers: [ "8.8.8.8", "8.8.4.4" ]
  cobbler_name_servers_search: example.com
  cobbler_interfaces:
    eth0:
      bonding: slave
      bonding_master: bond0
      macaddress: DE:AD:DE:AD:BE:ED
    eth1:
      bonding: slave
      bonding_master: bond0
      macaddress: DE:AD:DE:AD:BE:EF
    bond0:
      bonding: master
      bonding_opts: "mode=active-backup miimon=100"
      static: true
      ipaddress: 192.168.1.100
      subnet: 255.255.255.0
      gateway: 192.168.1.1
{% endhighlight %}

However, you can easily change the "schema" that it expects by modifying enc_parser.py. The entirety of the ENC output is stored as a dict in self._enc, and there is a method that can you change for each information item.

The full documentation is on the github page, but to import a system into cobbler, it's as simple as running one command:

{% highlight bash %}
cobbler-import-enc -s www1.example.com
{% endhighlight %}

There are also options for bulk-importing many servers at once, which could be stored in a cron job.

A few people have asked why I don't just manage the cobbler server using a puppet provider directly, and there's a few reasons. I did try this, and the simplest reason is that my ruby coding skills are simply not up to par yet. Second, the way I would envision this working is that the individual server configurations would be included in the Cobbler server's ENC output. The problem with this is it could be extremely large, and Puppet would be a lot slower once you get to adding 5,000+ system records in Cobbler.
