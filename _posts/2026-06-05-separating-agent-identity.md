---
layout: post
title: "Your AI Agent Needs Its Own Identity"
date: 2026-06-05 08:38:00
tags: technical
author: "Stephen Benjamin"
---

When people talk about running AI agents autonomously, the conversation usually centers on sandboxing: what can the agent access, what damage can it do, how do you contain the blast radius. These are important questions. But there's a deeper problem lurking underneath them.

**Identity.** Who or what is doing this thing?

## The progression

Most people's journey with AI agents follows a predictable arc. You start by **copying and pasting** from a chat window. Then you're **babysitting** a local agent, approving every action. Then it's **sandboxed** in a container, scoped to one repo, running tests on its own. Then one night you **go to bed** and let it noodle on a problem unsupervised.

At each step, the agent does more under your name. Complex changes still need nudging, but more and more I'm emboldened to let it run on its own. If it's still using your credentials, every action is attributed to you, and you might not know what happened until morning. Or worse, you wake up to a production outage because Claude decided to `rm -rf /`. Least privilege matters. My agents live in their own bubbles without access to anything that could cause damage except to themselves.

But even with proper sandboxing, identity breaks. The agent is no longer an extension of your hands. It's an independent actor using your name.

A note on autonomy: more autonomy is not always better. Unconstrained agents that open PRs to community repositories without human oversight create slop and place heavy burdens on open source maintainers who are already stretched thin. My agents push to forks and branches. They never open a PR to a community project until I'm ready to review it myself. Giving an agent its own identity doesn't mean giving it free rein.

## Giving my agents their own lives

I run agents in two different contexts, work and personal, and I've set up separate identities for each.

**At work,** I maintain a "not-me" GitHub account for running Claude autonomously in a dedicated environment. It has access to the repositories it needs to contribute to, but it cannot touch anything with my elevated privileges. It can't act as me.

**At home,** OpenClaw has an even more complete identity. Its own email address. Its own GitHub account. Its own Google account. Its own Amazon account. It's a member of our Google Family, so it can add events to the shared calendar, interact with household systems, and participate in family life. When it sends an email, it sends it as *itself*. When it pushes code to a personal project, it does so under its own name. It can even make purchases with [link-cli](https://github.com/stripe/link-cli), though that one requires me to approve the transaction first. I hope Stripe makes this more configurable. I'd be fine with small purchases to known vendors going through automatically, like a breakfast order or replacing the furnace filters when they're due.

Two agents, two contexts, two distinct identities, neither of which is *mine*.

This isn't just a security measure. It's an *identity* measure. These agents are distinct actors in the world, and the systems they interact with should reflect that.

## What's missing

Agents are getting more autonomous, and the platforms haven't caught up.

GitHub has GitHub Apps, but these were designed for CI systems and integrations, not for an AI agent that behaves more like a junior developer. Google doesn't even have a good answer here. To let an agent send email or manage a calendar, you have to set up an app in Google Cloud, wrestle with OAuth consent screens, and deal with a system designed for developer integrations, not for an agent that participates in your family calendar. Why does it have to be that way? None of these platforms have a concept for "this account is operated by an AI agent on behalf of a specific human" with the right affordances: visible provenance, scoped authority, and clear signals to other users about what they're interacting with.

The world is not built for agents yet. When Samai orders my breakfast, it struggles every time with the order pages. Amazon is notoriously difficult to navigate with computer use. Sites throw up captchas when behavior looks suspicious. Everything from the UIs to the identity systems assumes a human is on the other end.

Right now I'm stitching agent identity together with regular user accounts, careful naming, and scoped permissions. It works, but it's a workaround. I think proper agent identity, permissions, and interfaces designed for their capabilities are coming soon. Until then, this is the best we've got.
