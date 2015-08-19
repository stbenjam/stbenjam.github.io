---
layout: post
title:  Digital Emigration - De-Americanizing My Digital Life
date:   2013-08-16 10:13:00
categories: technical
---

I thought it would be worthwhile sharing my experience de-Americanizing my digital life.  That mostly means finding alternatives to all the Google services I've used over the years.  Of course the spying scandals played a role in this decision, but also the finickiness of Google to end services at will makes me feel like I'd rather have control over my own "digital life," and with less exposure to the U.S.

<strong>E-mail, Calendaring, Contacts</strong>

I've replaced my Gmail account by a self-hosted solution<a href="http://www.hetzner.de/"> on a server located outside the United States</a>.  You could install Postfix, Courier IMAP, and a variety of other tools in a roll-your-own solution.  I've done that in the past, but it's a hassle when there's free open source products like <a href="https://www.zimbra.com/downloads/os-downloads.html">Zimbra OCS </a>which gets you up and running quickly.  Push via ActiveSync is possible with the (relatively) low cost plug-in from <a href="http://www.zextras.com/">ZeXtras</a>.  I also use the backup plug-in from ZeXtras.

Zimbra has <a href="https://www.zimbra.com/forums/migration/24675-maildir-zimbra.html">native tools to import Maildir directories</a>, and you can use <a href="http://offlineimap.org/">offlineimap</a> to download your existing mail.  Other information can be downloaded from <a href="https://www.google.com/takeout/">Google Takeout</a>.

Regardless of where your e-mail is hosted, however, the NSA can easily scoop a lot up as e-mail is often transferred in plaintext between mail servers.

Use <a href="http://www.gpg.org/">GPG</a> whenever possible, here's <a href="https://bitbin.de/gpg.txt">my key</a>.

<strong>GTalk</strong>

I use <a href="http://www.twitter.com/">Twitter</a> more for casual communication, and freenode for geeky friends.  I was also hosting my own Jabber server with <a href="http://www.igniterealtime.org/projects/openfire/">OpenFire</a>, but it's not worth the trouble/risk for a single-user chat server.  Chaos Computer Club offers free accounts on <a href="http://web.jabber.ccc.de">jabber.ccc.de</a>, and you can reach me at stbenjam@jabber.ccc.de. Despite Google's announcements, it still seems possible to talk to GTalk users with my CCC XMPP account.

<strong>Google Reader</strong>

I didn't have a choice in abandoning this service, given that Google killed it -- which alone is a good reason to stop relying on "cloud" services.  I've tried a few of the alternatives like Feedly, but I'd prefer to have things in my own control.

I really like <a href="http://www.allthingsrss.com/rss2email/getting-started-with-rss2email/">rss2email</a> which, with a cronjob and e-mail filters, works great!

<strong>Replacement for Google Drive (or Dropbox)</strong>

Admittedly, I still use Dropbox and pay for extra space even though it's located in the U.S.A.  I've used the service for a really long time and it's reliable, and the syncing works well.  I'm not particularly concerned about the privacy issues here as my entire Dropbox is encrypted using EncFS.  <a href="https://www.boxcryptor.com/">BoxCryptor</a> is a pretty front-end to EncFS, if one likes that kind of thing.

I wouldn't consider using any hosted solution, especially one in the U.S.A., unencrypted.

In the do-it-yourself space, <a href="http://owncloud.org/">ownCloud</a> can do files (as well as contacts, calendaring, and a bunch of other things with plug-ins).  There's a number of other solutions out there ranging from hosting your shared storage in a git repo, to using Amazon S3 as a backend.  Just <del>Google</del> Duck Duck Go it.

<strong>Search</strong>

I tried <a href="http://www.duckduckgo.com/">Duck Duck Go</a>, but it's just not as good.   I tried <a href="http://www.bing.com/">binging</a>  things, too.  Unfortunately, I haven't found a good replacement for Google Search, but you could at least set  <a href="https://encrypted.google.com/">the encrypted search</a> as your default, but Google still keeps all the logs for this, it just prevents snooping on the wire.

<strong>Chrome</strong>

Like search, I've found the alternatives are not as good.  Firefox is improving but I still prefer Chrome's experience.  Regardless, I've gone back to Firefox.
