---
layout: post
title:  Add Google Reader Feeds to rss2email 
date:   2013-06-26 15:47:00
categories: technical
---

I've been experimenting with rss2email as a replacement for Google Reader.  Here's some ugly bash/python to use to get your XML feeds imported.

Get subscriptions.xml from your Reader dump available at <a href="https://www.google.com/takeout/">Google Takeout</a>, then put it in /tmp.

{% highlight bash %}
for feed in $(python -c "exec('from BeautifulSoup \
import BeautifulSoup as s\nfor f in [f[\"xmlurl\"]\
for f in s(open(\"/tmp/subscriptions.xml\")).findAl\
l(\"outline\") if f.has_key(\"xmlurl\")]:\n\tprint \
f')"); do r2e add $feed; done
{% endhighlight %}
