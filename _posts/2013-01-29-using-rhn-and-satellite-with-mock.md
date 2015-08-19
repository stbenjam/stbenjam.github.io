---
layout: post
title:  Using RHN (and Satellite) with Mock
date:   2013-01-29 05:19:00
categories: satellite mock rhel packaging technical
---

<a href="http://fedoraproject.org/wiki/Projects/Mock">Mock</a> creates chroots and builds packages in them. However, the default is to build against CentOS and EPEL, which isn't ideal when you're using a RHEL environment.

Thankfully, it's easy to point Mock to use the RHN channels your system is subscribed to.  However, this does limit you to building packages for the RHEL release your system is running.  For the example below you'd create this file as /etc/mock/rhel-6-x86_64.cfg.

{% highlight python %}
config_opts['root'] = 'rhel-6-x86_64'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install bash bzip2 coreutils cpio diffutils findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which xz'
config_opts['dist'] = 'el6'

config_opts['yum.conf'] = """
[main]
cachedir=/var/cache/yum
debuglevel=1
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
plugins=1
syslog_ident=mock
syslog_device=
"""

config_opts['rhnplugin.conf'] = """
[main]
enabled = 1
gpgcheck = 0
"""
{% endhighlight %}


What if you want to build for RHEL5 on your RHEL6 build machine, or some future version of RHEL? You'll need to have a local RHN Satellite, but you can reference the kickstart tree. Unfortunately, not all channels will work as yum repositories, only the kickstart trees, like as shown in the baseurl= line are accessible:

{% highlight python %}
config_opts['root'] = 'rhel-5-x86_64'
config_opts['target_arch'] = 'x86_64'
config_opts['legal_host_arches'] = ('x86_64',)
config_opts['chroot_setup_cmd'] = 'install bash bzip2 coreutils cpio diffutils findutils gawk gcc gcc-c++ grep gzip info make patch redhat-rpm-config rpm-build sed shadow-utils tar unzip util-linux-ng which xz'
config_opts['dist'] = 'el5' # only useful for --resultdir variable subst
config_opts['macros']['%dist'] = ".el5"
config_opts['plugin_conf']['ccache_enable'] = False

config_opts['yum.conf'] = """
[main]
cachedir=/var/cache/yum
debuglevel=1
reposdir=/dev/null
logfile=/var/log/yum.log
retries=20
obsoletes=1
gpgcheck=0
assumeyes=1
plugins=0
syslog_ident=mock
syslog_device=

# repos
[base]
name=BaseOS
enabled=1
baseurl=http://XXXXXXXXXXXXXXX/ks/dist/ks-rhel-x86_64-server-5-5.8/Server

"""
{% endhighlight %}
