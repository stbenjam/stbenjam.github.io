---
layout: post
title: An Agentic Future Is Already Here
date: 2026-03-27 12:00:00
tags: technical
author: "Stephen Benjamin"
---

Last weekend and throughout the week, I set out to try as many agentic AI tools as I could. Professionally, I wanted to understand how these tools fit into the software development lifecycle. But I also wanted to survey where the broader "agentic" space really is right now. I tested a bunch: some focused on software development ([Ambient Code](https://ambient-code.ai/), [Devin](https://devin.ai/), various CLIs), and others that are platforms for general-purpose agentic action (the "claws"). I spent time with [NanoClaw](https://github.com/qwibitai/nanoclaw), [OpenClaw](https://github.com/openclaw/openclaw), [Nanobot](https://github.com/HKUDS/nanobot), and a homegrown thing that I can only describe as three Claudes in a trenchcoat ([Claude Code's](https://docs.anthropic.com/en/docs/claude-code) `/loop`, scheduled triggers, and a prayer).

NanoClaw was appealing for its simplicity, but it has a heavy Ubuntu focus and is tightly coupled to Claude Code. I love Claude Code. I use it constantly, and it has the best plugin ecosystem of any AI tool I've used. But being locked to one vendor makes me uneasy.

OpenClaw is what I liked the most. It's big. It's sprawling. I'm mildly worried it'll go off the rails at some point. But with cautious use, it's been remarkably capable. Here's what a week with it actually looked like.

## Meet Syl

My assistant is named Sylphrena, Syl for short, an Honorspren from Brandon Sanderson's *Stormlight Archive*.  She wakes up fresh every session. Continuity comes from a set of files in her workspace: `SOUL.md` (personality), `USER.md` (who I am), `MEMORY.md` (long-term learnings), and daily memory logs. It sounds simple. It works surprisingly well.

## The Heartbeat Loop

Every 30 minutes, Syl runs a heartbeat. I define what she checks in a `HEARTBEAT.md` file: email, package tracking, stock quotes, calendar, whatever I want monitored. She runs through the list, decides what's actually worth my attention, and pings me on Telegram only when something matters. Everything else gets logged quietly.

She caught a NAS failure at 4 AM. She notified me when my USPS package arrived at my home post office. She gave me a heads-up when NVDA dropped past -4.75% pre-market. She also automatically picks up new tracking numbers from shipment notification emails. The stuff that doesn't clear her bar? I never hear about it.

## MailGuard: A Sane Email Layer

Email is a potent attack vector. Pulling untrusted content into an agent's context window is dangerous. So I built [MailGuard MCP](https://github.com/stbenjam/mailguard-mcp), a local mail proxy that only shows full message contents from explicitly trusted senders. Everyone else appears as `<untrusted_sender>` with just their address. Claude Code had the whole thing ready in about 15 minutes.

The MCP runs isolated in its own agent with no access to other tools. Frontier models were already pretty good at catching prompt injection on their own (Syl called my own prompt injection attempt "garbage"), but I like the belt-and-suspenders approach.

## Skills

OpenClaw uses a skills system where each skill is a directory with a markdown file describing what it does and how to use it. I set up skills for stock quotes, a daily morning briefing, automatic download of newly available library holds from Libby, and AMC movie booking.

The AMC skill was the most fun. It drives a Chrome browser on its own. I asked Syl to book me a ticket for *Project Hail Mary*, she picked a seat, described it, and asked for approval. I changed my mind on the showtime halfway through, so she canceled, refunded, and rebooked. The skill was written *during* that session, based on what she learned.

## Things Don't Always Go Smoothly

This is not magic. I asked Syl to warm up my car via Home Assistant and she struggled for several minutes before I realized my Tesla Fleet API token had expired. Booking dinner via Resy didn't work either. I suspect they have some bot detection mechanism (the search bar appeared functional but silently did nothing). I didn't dig into it.

## Do I Really Need an LLM for This?

Let's be real: most of what the heartbeat does could be a shell script. Fetch a stock price, check a tracking number, send a Telegram message. None of that requires a language model. I could wire it up with `curl` and `jq` in an afternoon and burn zero tokens.

But the value isn't in any single task. It's in the glue. Syl decides *whether* something is worth telling me about. She compares today's stock snapshot to yesterday's and writes a different kind of message depending on how bad it is. She reads an email subject line and decides it can wait. She notices that a package tracking status changed from "in transit" to "out for delivery" and flags it, but ignores the five intermediate scans that don't matter.

That judgment layer is what makes it feel like an assistant instead of a cron job. Could I hand-code all those heuristics? Sure. But then I'm maintaining a pile of brittle if-statements that break the first time the world does something I didn't anticipate. The LLM handles the long tail for a few cents a run.


## Models and Costs

An always-on agent burns tokens fast. I nearly exhausted my OpenAI Codex budget ($20 plan) in two days, and my Anthropic plan is close behind. For simple scheduled tasks, Qwen 3 8B running locally does fine. For the heavier stuff, Ollama Cloud's GLM-5 seems like a great deal and would probably get me through the month.

I also spent a fair amount of time on context management, stripping out a lot of what OpenClaw includes by default. It is not nearly as efficient as Claude Code's context handling, and the extra tokens add up when you're running heartbeats every 30 minutes.

## What's Next

Syl has been running for a week and the setup already feels essential.

The agentic future is messy, risky, expensive, and not always reliable. It's also already here, and it's useful enough that I'm not turning it off.

---

*Syl helped write this post. I asked her to review everything we did together over the past week in OpenClaw and pull out the highlights. She drafted sections, I rewrote them, and we went back and forth until it read right. She approved the final version.* 🌬️
