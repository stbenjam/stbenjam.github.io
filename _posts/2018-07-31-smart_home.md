---
layout: post
title:  Smart Home Walkthrough
date:   2018-07-31 19:53:00
categories: technical
---

My "smart house" started out as a couple of Hue light bulbs in my
apartment. Now that we've bought a house, I started acquiring a few more
smart things here and there, and over the last couple of months I
finally decided to integrate them all together using an open source
project called Home Assistant.

To be honest, I didn't start out with a plan, and I wish I had. However,
with few exceptions all the things I've bought play nicely together.
Home Assistant has allowed me to develop a number of interesting
things.

When no one is at home, the house puts itself in away mode: lights and
televisions get turned off, my thermostat temperatures set to Eco mode,
and all of the doors get locked.  Presence detection is done through the
Unifi module, which looks for devices on our main and Guest WLAN's.

Home Assistant is also fully integrated with Amazon Alexa through the HA
Cloud project. I'm able to control all my devices through HA instead of
using each platform's integration.  Custom skills even do things like
report on my solar system, or answer questions about if someone is home.

![Home Assistant](/static/images/2018/ha.gif)

I also use HADashboard and an old iPad mounted to the kitchen wall:

![HADashboard](/static/images/2018/hadashboard.png)

# Home Network

Goal number one when we moved into the house was getting it wired for
CAT6, and a small equipment rack installed in the basement. I switched
over from DD-WRT to Unifi last year, and now that I'm in the house I've
bought a few more Unifi things.  My network consists of:

- UniFi security gateway
- 8 port 60W POE Switch
- 8 port switch
- 2x UniFi AP-AC-Pro

The main challenge was getting the CAT6 to the various rooms, and
learning how to punch down a keystone jack.  I ended up buying a spool
of CAT6 on Amazon along with keystone jacks, wallplates, a cable
tester, etc.  It was slow-going at first, but I managed to finagle
network drops to all the rooms I wanted: living room, office, kitchen
for the access point, and the basement family room.  Each room has
several drops going to it, as I never really want to have to do this
again! Although eventually I plan to add some POE cameras, so I may have
to run some network drops outside.

The network is split into 3 VLAN's, with limited connectivity between
each:

- Main network
- Guest network
- Internet of ~~Shit~~ things

# Lighting

My first "smart house" devices were Hue light bulbs, but now that I
actually owned the property I could use a little bit more full featured
smart switches instead. All my reading lead me to narrow down my options
to Z-Wave switches from GE, Lutron Caseta and Insteon. Insteon has a
large ecosystem of smart things, and came highly reccomended from a
friend of mine. But Caseta devices were easily available locally, and
they're *pretty*, especially with the Claro wall plates.

![Lutron Caseta](/static/images/2018/caseta.jpg)

I've heard bad things about Z-wave range and reliability, although I do
actually own a few non-lighting Z-wave devices now. The downside to the
others is that both Lutron Caseta and Insteon are proprietary protocols,
with proprietary hubs. Lutron needs the Pro hub if you want an open
telnet port for reliable integration with third party tooling.  The
consumer hub has been reverse engineered from the Android app, and
there's a Home Assistant component but it breaks every so often.

Z-wave seems to be the way to go if you want a more open protocol, and
in retrospect now that I own a few Z-wave devices, I would probably have
used it for my lights too.

But, I am happy with Lutron. It works well with Home Assistant, and
their customer service is top notch.

# Nest Ecosystem

Through my utility provider, I bought a Nest thermostat at a substantial
discount.  It was my first Nest product, and despite being owned by
Google, has a pretty open API.  I later bought Nest Protect fire alarms:
they looked nice, and the nightlight feature was really handy to light
up the hallway to the bathroom at 3 a.m.  I'm very happy with these
products. They integrate well with Home Assistant.

My last Nest product, however, was a different story.

# Locks

Being happy with the other Nest products, I decided on buying a Nest x
Yale lock. I made some assumptions that were wrong, based on my
experience with other Nest devices and the "Works with Nest" logo on the
box.

The lock has no API. It has no Amazon integration. It does, however,
have integration with Google Home.  I believe this is intentional on
Google's part to close down new Nest products from third party services,
and suck people into Google Home.  I sold my lock on eBay.

Now on the hunt for new locks, I came to the conclusion I might as well
bite the bullet and get into Z-wave.  I'm glad I did.  I bought 2 used
Yale 210's on eBay, and a Schalge Camelot for the main door. They didn't
work seemlessly, but I ended up needing to write a patch to fix some
quirks.

# Solar

A big consideration for me when I bought the house was having a good
potential for solar.  My house isn't in a perfect position, as it faces
southeast/northwest, but I was able to get panels on *both* sides
meaning in the end I fit a bigger system than I could have otherwise. I
have 30x 295W panels, for a total of 8.85kW, and an underclocked
SolarEdge 7.6kW inverter.  In the first month of operation, I produced
over 1100kWh - more than double our usage.  The net metering credits
from that production should help in the winter when there's less sun.

In addition to the solar, I'm on the waitlist for a Powerwall 2.  It
should be here in a month or two, but Tesla is known for being pretty
unreliable there.  I'm hoping it arrives before winter, and the plan is
to operate it in backup-only mode, taking over in the event of an
occasional power outage. With Home Assistant, I'll automate some power
conservation strategies like adjusting the thermostat, and turning off
power-hungry devices.

For now, I've integrated information about my solar from the SolarEdge
API using Home Assistant's REST sensors, which displays nicely on
HADashboard:

<div align="center">
<img src="/static/images/2018/solar.png" alt="Solar Dashboard" />
</div>
