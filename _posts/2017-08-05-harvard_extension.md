---
title: Harvard Extension's ALM in Software Engineering
date: 2017-08-05 10:56:00
categories: education
---

A few years ago, I finished my B.S. in Computer Science through
[UMUC](http://umuc.edu/), mostly online and while traveling in Germany as a
Consultant for Red Hat. When I moved back to the US, I knew I wanted to use the
remainder of my GI Bill entitlement on a Master's degree.  These days, there's
a lot of options for online programs - for example, Georgia Tech's online MSCS
program.  My coworker did a nice [write
up](http://blog.daniellobato.me/omscs-year-1-review/) of his experience so far.

I decided to opt for a local program, and narrowed down my choices between
Tuft's part-time [M.S. in Computer Science](http://www.cs.tufts.edu/Master-of-Science-in-Computer-Science-Degree/part-time-masters-degree-program-in-computer-science.html),
and Harvard Extension's awkwardly named [_Master of Liberal Arts in extension studies, field: Software Engineering_](https://www.extension.harvard.edu/academics/graduate-degrees/software-engineering-degree).

There's a difference between computer science and software engineering, of course, but the Harvard ALM was flexible enough that I could include the theoretical stuff I wanted and it was easier to get to Harvard on public transportation.

The degrees from the extension school seem to be awkwardly named to differentiate the Extension school from the other more traditional schools at
Harvard, lest someone be confused that my degree came from [SEAS](https://www.seas.harvard.edu/).  Still, I don't get why it's a Master of
Liberal Arts, that's not really reflective of the coursework, and there's been [some effort to change that](http://www.thecrimson.com/article/2016/4/25/extension-school-rally-degrees/), although I doubt I'll ever see it as I'm nearly done.

I've mostly taken one course at a time, but this year my [awesome employer](http://www.redhat.com/) graciously let me take a leave of absence to study full time to wrap things up quickly as my GI Bill benefits expire soon.

## Courses

  - [CSCI E-97: Software Design Patterns](#csci-e-97-software-design-patterns)
  - [CSCI E-93: Computer Architecture](#csci-e-93-computer-architecture)
  - [CSCI E-95: Compiler Design](#csci-e-95-compiler-design)
  - [CSCI E-28: Unix Programming](#csci-e-28-unix-programming)
  - [STAT E-100: Intro to Statistics](#stat-e-100-intro-to-statistics)
  - [PHYS S-123: Laboratory Electronics: Analog and Digital Circuit Design](#phys-s-123-laboratory-electronics-analog-and-digital-circuit-design)
  - CSCI E-55: Java, Hadoop, Lambda Expressions, and Streams (Fall 2017)
  - CSCI E-15: Dynamic Web Design (Fall 2017)
  - CSCI E-134: Networks (Fall 2017)
  - CSCI E-599: Capstone (Spring 2018)

### CSCI E-97: Software Design Patterns

This class was a deep dive into software design patterns.  It taught most of
the key patterns from the "Gang of Four." It was also a heavy deep dive into
UML.

I thought the class was useful, but the material was dry.  It is a required
part of the ALM.

### CSCI E-93: Computer Architecture

This and the following two classes (CSCI E-95, and E-92) were my best
experience at Harvard so far. I used this class as my "theoretical foundations"
requirement for the 3 admissions courses.

In this class, I built a computer processor from scratch.  I designed an
instruction set, wrote an assembler, an emulator, and then finally
implemented the processor using VHDL that ran on a physical piece of hardware
(an FPGA development board from Altera).  My final project video is on
[YouTube](https://www.youtube.com/watch?v=tsCXAeIYa7I).

This and the other 2 classes are designed such that if you work through each of
the problem sets, you'll get a working thing in the end.  Out of all 3 classes,
this one had more freedom as you could really design any kind of processor you
wanted.  Some people tried more adventurous things like stack machines or
getting pipelining working, but this was my first experience at this layer so I
ended up doing a 16-bit, mostly MIPS-like architecture.  My final project's
special feature was an LFSR.  Many students opt for interrupts or hardware
multipliers as theirs.

If you end up taking this, go to section.  It's extremely useful and a lot of
implementation suggestions are given.

If you want to take it with me, I'm a TA for the Fall 2017 class! It's available
as an online option, too.

### CSCI E-95: Compiler Design

I wrote a compiler for a large subset of C using C along with classic compiler
tools (Flex and Bison).  Whereas many other universities teach classes where
you only learn theory, or only implement a "simple" language - this class stood
out in that you literally write a compiler for C and have to understand all of
its quirks.

It's essentially C89 minus structs, unions, and function pointers.  The final
project is implementing an optimization stage in the compiler, mostly adding
simpler peephole optimizations on basic blocks. Many students also work on
more advanced register allocation strategies like graph coloring.

My final project video is [here](https://www.youtube.com/watch?v=H2SbDrAi0NI).

It's worth noting, I didn't know even know C when I started the class, but I
knew it pretty well by the end.

### CSCI E-92: Operating Systems

In this class, we learned the important operating system concepts, and then
implemented an OS on a Freescale K70 Tower.  You start out writing a small
shell, your own implementation of malloc, various system calls in the OS, and
towards the end of the class everything comes together when you write own
scheduler and get multitasking working.

My final project was a rather complete POSIX-like permissions system, and
interrupt-based Semaphores.  I also got multiple serial ports working on the
device, which made the demos a little more interesting.

My final project video is [here](https://www.youtube.com/watch?v=gO7zeiHN-RQ).

### CSCI E-28: Unix Programming

This class dives into the details of how POSIX systems programming works (and
more specifically, the class touches on a lot of Linux-specific things).  I
took this concurrently with CSCI E-92, which it was a nice complement for.  I'd
reccomend taking this first, or also concurrently, to see how real operating
systems design their system calls.

During this class, I wrote a shell (a bit more complex than the one I wrote for
CSCI E-92), a pong game using curses, as well as a multithreaded web server for
my final project.  I wouldn't say this is a particularly demanding course if
you're already familiar with Unix-like operating systems and know C.  Most of
the problem sets come with significant starter code.

The class is taught by the author of [Understanding UNIX/LINUX Programming](https://www.amazon.com/Understanding-UNIX-LINUX-Programming-Practice/dp/0130083968/).

### STAT E-100: Intro to Statistics

This class was underwhelming.  I was hoping for a deeper dive into R, but it
was much more using R as a REPL with 99% of the R code given to us.  It
provided a good introduction to statistical concepts, but was rather shallow in
the depth of the topics that were covered.

I also took this as an online-only class, as it was the only stat class that'd
fit into my schedule.  The video lectures were really great, however the
problem sets were not very challenging and mostly multiple choice.  I expected
it to be a little harder, and was disappointed I blew one of my elective slots
on this class considering I could've got this out of Khan Academy on my own.

There's a few other statistics classes at Harvard Extension (100, 102, 110,
etc), offered by a number of different instructors.  Perhaps some are better
than others.

### PHYS S-123: Laboratory Electronics: Analog and Digital Circuit Design

This was an 8-credit (2 course) summer program that ran Monday through Thursday,
9 to 1pm (officially) over seven weeks. On days with labs, the time was more
realistically 2:30 or 3pm. Add on homework and study time, I was getting home
in the evening nearly every day.

Typically, this is taught as two separate classes: a semester on analog
electronics and a semester on digital electronics.  This summer school version
is intense - covering this amount of material in 7 weeks is daunting, and for
the summer course some of the more interesting things are removed.  Instead
of the "big board" path where you build up your own computer on breadboards,
we worked with a SiLabs microcontroller that had most everything built-in.

Still, it was a great experience and I'm glad I took this class. The analog
section starts off covering voltage, current, and resistance and building
passive circuits.  It moves on to transistors, both BJT and MOSFETs, and you
go on to build an op amp from discrete parts to understand what's inside.  It
goes on to cover op amps in detail covering usages of positive and negative
feedback, and on the final day of the analog part of the course, we designed
and built a group project that transmitted and received an audio signal using
infrared light.

The digital part of the class starts off with boolean logic, HDLs, and logic
gates. CSCI E-93 covered a lot of this, but the electronics were abstracted
away from us in VHDL.  In this course, you look at what's actually inside both
TTL and CMOS logic gates, build analog-to-digital or digital-to-analog
converters from parts, design and build state machines using flip flops, etc.
The final week of the class is working with the SiLabs microcontroller, and
writing assembly programs for it.

The text book we used is [The Art of Electronics](https://www.amazon.com/Art-Electronics-Paul-Horowitz/dp/0521809266/ref=sr_1_1), along
with the accompanying student lab manual.

## What's left?

So the above is everything I've taken so far.  For Fall 2017, I'm taking
my final three classes before I take the capstone:

  * CSCI E-134: Networks - Explores game theory, social networks, etc at the intersection of economics and computer science. This one is run concurrently with the Harvard College version of the class.

  * CSCI E-15: Dynamic Web Design - A web design class is required, I wish I could've swapped this out for a more interesting elective.  The class itself looks well put together.

  * CSCI E-55: Java and Hadoop - another required class, this meets the "Cloud" requirement.  It's a Java for programmers class.  I already know Java, but it looks like the latter half the class covers Hadoop and the functional programming features of Java 8 which should be interesting.

And in Spring 2018, I only have to take the capstone course, which is the final
course in the Master's program.  It involves a group project.

Alternative to the capstone is a thesis track.  I still wonder if I should switch to it, but it'd delay my graduation by about a year.  I still have a few months to make a final decision and get a proposal ready if I decided to go that route.

If you want to know anything else, let me know!
