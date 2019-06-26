---
layout: post
title:  Foreman FreeIPA Integration Guide
date:   2013-11-11 20:57:00
categories: foreman technical
---

<div align="center" style="border: 1px solid black"><strong><br>

<span style="color: red">Note!</span> In Foreman 1.5, <a href="http://theforeman.org/manuals/1.5/index.html#4.3.11FreeIPARealm">FreeIPA realm join integration</a> is now built-in!<p></p>
</strong>
</div>
<br>

<p>Two projects that I'm really loving at the moment are The Foreman and FreeIPA.

<a href="http://theforeman.org/">The Foreman</a> is lifecycle management tool for physical and virtual servers (think Cobbler on PCP), and  <a href="http://www.freeipa.org">FreeIPA</a> provides central authentication: directory services, kerberos, policy enforcement, and a PKI infrastructure.

Why not glue them together? This is my first attempt, and it's all a bit manual and unpolished. There's an effort to get this integration into the Foreman Smart Proxy itself.

<h3>All of the scripts here are in a <a href=" https://gist.github.com/stbenjam/7420158">Github Gist</a>.</h3>

The goals here are:

<ul>
<li>Foreman authenticates against FreeIPA</li>
<li>Signed Certificates for Foreman, Puppetmaster, and Clients</li>
<li>New Hosts automatically register to IPA and get a signed certificate</li>
<li>A host gets deleted from IPA when it is deleted from Foreman</li>
</ul>

<h3>Prerequisites</h3>

<ul>
<li>Installed Foreman Server on a Red Hat-based distro (RHEL, CentOS, Fedora, et al).</li>
<li>Foreman server is registered to FreeIPA</li>
<li>Installed FreeIPA (or Red Hat IdM) Server</li>
</ul>

<h2>Contents</h2>
<ol>
<li><a href="#foreman-ldap-auth">Foreman LDAP Authentication</a></li>
<li><a href="#freeipa-certs">FreeIPA PKI Infrastructure</a></li>
<li><a href="#automatic">Automatic IPA Registration/Deletion</a></li>
</ol>



<a id="foreman-ldap-auth"><h2>Foreman LDAP Authentication</h2></a>

<strong>End Goal</strong>: Users can login to the Foreman using FreeIPA credentials.  Individual access rights still need to be granted in the Foreman GUI itself, though.

Based on the <a href="http://www.freeipa.org/page/EJabberd_Integration_with_FreeIPA_using_LDAP_Group_memberships">FreeIPA Ejabberd Integration Guide</a>


<ol>
<li>Create a foreman.ldif file, replacing dc=bitbin,dc=de with your DN, and providing an appropriately secure password:
{% highlight bash %}
dn: uid=foreman,cn=sysaccounts,cn=etc,dc=bitbin,dc=de
changetype: add
objectclass: account
objectclass: simplesecurityobject
uid: foreman
userPassword: 8j926SEpcOvM0WLI
passwordExpirationTime: 20380119031407Z
nsIdleTimeout: 0
{% endhighlight %}

</li>
<li>Import the LDIF (change localhost to an IPA server if needed), you'll be prompted for your Directory Manager password:
{% highlight bash %}
# ldapmodify -h localhost -p 389 -x -D \
"cn=Directory Manager" -W -f foreman.ldif
{% endhighlight %}
</li>
<li>Add an IPA group for foreman_users (optional):
{% highlight bash %}
# ipa group-add --desc="Foreman Users" foreman_users
{% endhighlight %}
</li>
<li>Now login to the Foreman as an Admin, click on "LDAP Authentication" under More/Users.  Then click New LDAP Source and fill in the details, changing dn's where appropriate to your own domain:
<p>
<ul>
<li>Server: astriaporta.bitbin.de</li>
<li>Port: 636</li>
<li>TLS: checked</li>
<li>Account username: uid=foreman,cn=sysaccounts,cn=etc,dc=bitbin,dc=de</li>
<li>Account password: 8j926SEpcOvM0WLI</li>
<li>Base DN: cn=accounts,dc=bitbin,dc=de</li>
<li>Filter (optional):&nbsp;(memberOf=cn=foreman_users,cn=groups,cn=accounts,dc=bitbin,dc=de)</li>
<li>Automatically create accounts in the Foreman: checked</li>
<li>LDAP mappings are as the examples given.</li>
</ul>
</li>
</ol>

<a id="freeipa-certs"><h2>FreeIPA Certs for Foreman + Puppet</h2></a>

<b>End Goal:</b> Foreman and the Puppetmaster use certificates from the FreeIPA server.

<ol>
<li>Backup the existing SSL directory:
{% highlight bash %}
# mv /var/lib/puppet/ssl /var/lib/puppet/ssl.old
{% endhighlight %}
</li>
<li>Make the appropriate directory structure:
{% highlight bash %}
# mkdir -p /var/lib/puppet/ssl/{private_keys,certs}
{% endhighlight %}
</li>
<li>For the next steps you need to have a Kerberos ticket for a user with sufficient privileges (e.g. admin)
{% highlight bash %}
# kinit admin
{% endhighlight %}
</li>
<li>Create the service principal:
{% highlight bash %}
# ipa service-add puppet/`hostname`
{% endhighlight %}
</li>
<li>Request certificates from the IPA server
{% highlight bash %}
# ipa-getcert request -K puppet/`hostname` -D `hostname` \
 -k /var/lib/puppet/ssl/private_keys/`hostname`.pem \
 -f /var/lib/puppet/ssl/certs/`hostname`.pem
{% endhighlight %}
</li>
<li>Check on the request, you should see the status as MONITORING if successful:
{% highlight bash %}
# ipa-getcert list
Request ID '20131106211000':
    status: MONITORING
    stuck: no
    key pair storage: type=FILE,location='/var/lib/puppet/ssl/private/gatebuilder.bitbin.de.pem'
    certificate: type=FILE,location='/var/lib/puppet/ssl/certs/gatebuilder.bitbin.de.pem'
    CA: IPA
    issuer: CN=Certificate Authority,O=BITBIN.DE
    subject: CN=gatebuilder.bitbin.de,O=BITBIN.DE
    expires: 2015-11-07 21:10:01 UTC
    eku: id-kp-serverAuth,id-kp-clientAuth
    pre-save command:
    post-save command:
    track: yes
    auto-renew: yes
{% endhighlight %}
</li>
<li>Copy the IPA CA.cert:
{% highlight bash %}
# cp /etc/ipa/ca.crt /var/lib/puppet/ssl/certs/ca.pem
{% endhighlight %}
</li>
<li>Take a peek in the SSL directories, and you'll see our new certs:
{% highlight bash %}
# ls  {private_keys,certs}
certs:
ca.pem  gatebuilder.bitbin.de.pem

private_keys:
gatebuilder.bitbin.de.pem
{% endhighlight %}
<li>Make sure permissions are sensible:
{% highlight bash %}
# chown -R puppet:puppet /var/lib/puppet/ssl
# chmod 600 /var/lib/puppet/ssl/{private_keys,certs}/`hostname`.pem
{% endhighlight %}</li>
<li>Edit /etc/puppet/puppet.conf:
<ul>
<li>Add to [main]:
{% highlight bash %}
# This disables the CRL.  I need to fix this at a
# later time
certificate_revocation = false
{% endhighlight %}</li>
<li>In [master], change:
{% highlight bash %}
ca = false
{% endhighlight %}
</li>
<li>Restart httpd (Foreman-configured Puppet runs in Passenger):
{% highlight bash %}
# service httpd restart
{% endhighlight %}</li>
</ul>
</li>
<li>Browse to the Foreman, and you should see it using the new SSL certificates signed by your IPA CA.  Ideally you should import the IPA CA.crt on your local box and trust it.</li>
</ol>

<a id="automatic"><h2>Registration at Provision-Time</h2></a>

The idea here is that our machines when foreman creates them are automatically registered to FreeIPA <em>with a one-time password</em>, and if later deleted in the Foreman, they are removed from FreeIPA too. Hosts also get an SSL certificate signed by the FreeIPA server to talk to puppet.  The flow looks like this:

<a href="/images/2013/11/freeipa_foreman.png"><img src="/images/2013/11/freeipa_foreman.png" alt="Here&#039;s a really confusing graphic that may or may not make things clearer" width="590" height="310" class="size-full wp-image-1107" /></a>

<h3>Creating IPA User with Right Permissions</h3>

<b>A previous version of this guide called this user "foreman" - don't do that, it'll interfere with upgrading later, as the RPM packaging expects to use a local user named "foreman."</b>

<ol><li>Create the user:

{% highlight bash %}
# kinit admin
Password for admin@BITBIN.DE:
# ipa user-add --first="The" --last="Foreman" foreman_reg \
--password
Password:
Enter Password again to verify:
--------------------
Added user "foreman_reg"
--------------------
{% endhighlight %}</li>
<li>Grant host enrollment privileges:
{% highlight bash %}
# ipa role-add-member --users=foreman_reg "Host Enrollment"
{% endhighlight %}
</li>
<li>We need to modify the Host Enrollment role to actually allow the Foreman user to add brand new hosts and delete them too -- so Foreman can completely manage the machine lifecycle.
{% highlight bash %}
# ipa privilege-add-permission 'Host Enrollment' \
--permissions='Add Hosts'
# ipa privilege-add-permission 'Host Enrollment' \
--permissions='Remove Hosts'
{% endhighlight %}

</li>
<li>Change foreman password after first time:
{% highlight bash %}
[root@gatebuilder ~]# kinit foreman_reg
Password for foreman_reg@BITBIN.DE:
Password expired.  You must change it now.
Enter new password:
Enter it again:
{% endhighlight %}
</ol>

<h3>Configuring the Create/Destroy Hook</h3>

Grab the scripts from the <a href="https://gist.github.com/stbenjam/7420158">Github Gist</a>.

<ol>
<li>On Foreman, install the hooks gem:

{% highlight bash %}
# yum -y install ruby193-rubygem-foreman_hooks
{% endhighlight %}

</li>
<li>And make the directory structure we need:

{% highlight bash %}
# mkdir -p /usr/share/foreman/config/hooks\
/host/managed/{create,destroy,after_commit}
{% endhighlight %}

</li>
<li>Put foreman-ipa into /etc/sysconfig/ with the right permissions
{% highlight bash %}
# chown foreman /etc/sysconfig/foreman-ipa
# chmod 600 /etc/sysconfig/foreman-ipa
{% endhighlight %}
</li>
<li>Configure /etc/sysconfig/foreman-ipa
{% highlight bash %}# Are we using IPA as the CA?
CREATE_SERVICE_PRINCIPAL=true

# Allow Foreman to delete hosts from IPA
PREVENT_DELETING_HOSTS=false

# Hostname of an IPA server
IPA_SERVER="astriaporta.bitbin.de"

# User with appropriate permissions
IPA_USER="registration"
IPA_PASS="password"

# Foreman API User/Password
FOREMAN_USER="apiuser"
FOREMAN_PASS="apipass"
{% endhighlight %}

<li>Put 10_integrate_freeipa.sh into /usr/share/foreman/config/hooks/host/managed/create and create a symlink to destroy and after_commit:
{% highlight bash %}# ln -s /usr/share/foreman/config/hooks\
/host/managed/create/10_integrate_freeipa.sh ../destroy
# ln -s /usr/share/foreman/config/hooks\
/host/managed/create/10_integrate_freeipa.sh ../after_commit
{% endhighlight %}
</li>

<li>Restart foreman to get it to notice the new hooks:
{% highlight bash %}
# service foreman restart
# service httpd restart
{% endhighlight %}
</li>

<li>Take a look at the logs to make sure the hooks were registered, look in /var/log/foreman/production.log:
{% highlight bash %}
Finished registering 1 hooks for Host::Managed#destroy
Finished registering 1 hooks for Host::Managed#after_commit
Finished registering 1 hooks for Host::Managed#create
{% endhighlight %}
</li>

<li>The last step in this is integrating into your provisioning template.  You'll need to get ipa-client installed in your packages list, and remove the other puppet registration thingy from the Foreman. I have a snippet that looks like this:

{% highlight bash %}
# Register to IPA, two times
# in case of https://fedorahosted.org/freeipa/ticket/3377
ipa-client-install --mkhomedir -w <%= @host.params['ipa_onetime'] %> -f -U
ipa-client-install --mkhomedir -w <%= @host.params['ipa_onetime'] %> -f -U

# Make Puppet Certificate Directories
mkdir -p /var/lib/puppet/ssl/{private_keys,certs}

# Generate IPA Certificate
ipa-getcert request -K puppet/<%= @host.name %>  -D <%= @host.name %> \
-k /var/lib/puppet/ssl/private_keys/<%= @host.name %>.pem \
-f /var/lib/puppet/ssl/certs/<%= @host.name %>.pem

# Workaround for "stack too deep" problem
# http://projects.puppetlabs.com/issues/21869
cp /etc/ipa/ca.crt /var/lib/puppet/ssl/certs/ca.pem

cat <<EOF > /etc/puppet/puppet.conf
[main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet
    ssldir = /var/lib/puppet/ssl
    server = <%= @host.puppetmaster %>

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig

    certificate_revocation = false
    certname = <%= @host.name %>
EOF

puppet agent --test
chkconfig puppet on
{% endhighlight %}
<li>When the machine boots it will use one-time password authentication with FreeIPA and grab an SSL certificate for use with Puppet.  And you get the bonus of when you delete the machine in Foreman, it gets deleted in IPA too.</li>
</ol>



