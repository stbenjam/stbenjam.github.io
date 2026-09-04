---
layout: post
title: "The Code They Leave Behind"
date: 2026-09-04 07:40:08 -0400
tags: technical
author: "Stephen Benjamin"
---

I’ve been thinking a lot about what we’re actually trying to measure with coding benchmarks. Almost every major leaderboard evaluates models on a simple binary: did the model complete the task? That pass/fail metric hides the qualitative properties of the solution. A single score doesn't tell you how the code was built, how fragile it is, or whether you would ever want to maintain it.

Opus 5 is a great example of this gap. On paper, it looks like a massive improvement: on Terminal Bench 4.0, Opus 4.8 scored 23.6%, while Opus 5 jumped to 51.8%, surpassing Fable 5. But once developers actually started using it, many called the model practically unusable.

We see this cycle constantly: a new model lands, benchmarks hit record highs, and real-world utility fails to match the headline.

Because Terminal Bench is open source, we can inspect the exact artifacts these models leave behind. I analyzed 27 code-producing tasks through five views: reliability, verbosity, complexity, specialization, and writing.

[Read **The Code They Leave Behind** and explore the interactive graphs.](https://bitbin.de/qualitative-benchmarks/)
