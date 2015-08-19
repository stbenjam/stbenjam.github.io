---
layout: post
title:  Using Librarian with Katello
date:   2015-05-07 12:20:00
categories: technical puppet katello foreman
---

Currently, Katello doesn't handle dependency management for Puppet modules, but you can use librarian-puppet for this purpose.

Let's create a Puppetfile for our Content View:

{% highlight bash %}
forge "https://forgeapi.puppetlabs.com"

mod 'puppetlabs-apache'
mod 'puppetlabs-ntp'
{% endhighlight %}

Use `librarian-puppet package` to get the .tar.gz packaged modules:

{% highlight bash %}
# librarian-puppet package
{% endhighlight %}

At this point, you'll have a directory vendor/puppet/cache with all of the puppet modules including their dependencies.

{% highlight bash %}
vendor
└── puppet
    ├── cache
    │   ├── puppetlabs-apache-1.4.1.tar.gz
    │   ├── puppetlabs-concat-1.2.1.tar.gz
    │   ├── puppetlabs-ntp-3.3.0.tar.gz
    │   └── puppetlabs-stdlib-4.6.0.tar.gz
    └── source
{% endhighlight %}

Upload the modules with hammer:

{% highlight bash %}
# hammer repository upload-content --organization="BitBin"\
  --name "Local Forge" --product "Puppet Modules" --path vendor/puppet/cache


[Foreman] Username: admin
[Foreman] Password for admin: 
Successfully uploaded file 'theforeman-dns-2.0.1.tar.gz'.
Successfully uploaded file 'puppetlabs-concat-1.2.1.tar.gz'.
Successfully uploaded file 'puppetlabs-stdlib-4.6.0.tar.gz'.
Successfully uploaded file 'puppetlabs-apache-1.4.1.tar.gz'.
Successfully uploaded file 'theforeman-concat_native-1.4.0.tar.gz'.
Successfully uploaded file 'puppetlabs-ntp-3.3.0.tar.gz'.
{% endhighlight %}

But, you'll probably want to add them to a Content View, too.  This will require some fancy dancing with bash, but it appears `hammer puppet-module` is broken.  See: <a href="http://projects.theforeman.org/issues/10410" title="http://projects.theforeman.org/issues/10410">http://projects.theforeman.org/issues/10410</a>

If `hammer puppet-module` did work, some hacky shell script like this would do it:


{% highlight bash %}
#!/bin/bash

USER='admin'
PASSWORD='changeme'

ORGANIZATION=2
REPOSITORY=42

TARGET_CONTENT_VIEW=96

IFS=$'\n'
MODULES=$(librarian-puppet show)

for module in $MODULES
do
  echo ----- $module
  name=$(echo $module | cut -f1 -d\()
  version=$(echo $module | cut -d\( -f2 | cut -d\) -f1)

  module_id=$(hammer -u $USER -p $PASSWORD puppet-module list --repository-id=$REPOSITORY | grep $name | grep $version | cut -d\| -f1)
  hammer -u $USER -p $PASSWORD content-view puppet-module add --organization-id=$ORGANIZATION --content-view-id=$TARGET_CONTENT_VIEW --id=$module_id
done
{% endhighlight %}

