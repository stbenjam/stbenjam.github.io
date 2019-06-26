---
layout: post
title:  Why does Gmail hate my domain?
date:   2015-07-08 22:25:00
categories: technical
---

For 10 out of the last 15 years, I've run my own mail servers.  I switched to Gmail when it came out, but I decided I didn't want to have so much data in their hands.  So I took it away from them, and I've hosted it again myself for the last few years.  In the beginning, it was troublesome, I'd end up in spam folders everywhere.  But these days I don't have much issue with Yahoo or Hotmail/Outlook/MSN/whatever they are now - only Gmail is the outlier.

A few days ago, I attempted to e-mail a company regarding an online e-commerce order I had placed, from my personal address.  My email was rejected by Google and improperly identified as bulk e-mail. It's not an infrequent occurrence.  Either my mail ends up in spam folders, or they outright reject it:

<a href="/images/2015/07/google.png"><img src="/images/2015/07/google.png" alt="google" width="1021" height="244" class="aligncenter size-full wp-image-1512" /></a>

The e-mail headers google shows are fine - it passes both DKIM and SPF:

<a href="/images/2015/07/pass.png"><img src="/images/2015/07/pass.png" alt="pass" width="413" height="274" class="aligncenter size-full wp-image-1514" /></a>

My mail server is not in any blacklist, and any kind of diagnostics you want are GREEN.  I'm not an open relay, nor have I ever been.

<a href="/images/2015/07/ok1.png"><img src="/images/2015/07/ok1.png" alt="ok1" width="758" height="285" class="aligncenter size-full wp-image-1516" /></a>

What is my crime? I host a well-behaved mail server that's been around for at least a few years, that implements industry standards like DKIM and SPF correctly.  It has never sent a single spam, and barely sends mail at all - a couple hundred a year, maximum.  And all of a personal nature.

I can only think this is intentional on Google's part - they have a near monopoly; the vast majority of mail I send these days goes to Google - and if a small company is running their own mail server is too much of a hassle, then maybe they'd buy Google Apps.  It's bad, anti-competitive behavior on Google's part.  Shame on them if its true.  I don't know if it is, I can only guess, but they certainly have an incentive to make it difficult for the little guy.

I'm just a geek that likes running my own servers.  My pleas to Google's impersonal forms fall on deaf ears, and I'm getting tired of telling everyone I e-mail to check their spam folders.

What can I do except move to a hosted provider with a better reputation with Google?


