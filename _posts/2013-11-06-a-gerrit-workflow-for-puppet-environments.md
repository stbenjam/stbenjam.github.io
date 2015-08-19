---
layout: post
title:  A Gerrit Workflow for Puppet Environments
date:   2013-11-06 21:45:00
categories: technical puppet
---

Managing Puppet manifests in source control is nothing new. Puppet Labs has their own suggested workflow that uses <a href="http://puppetlabs.com/blog/git-workflow-and-puppet-environments">a git post-receive hook to automatically publish a git branch</a> as an environment. It's a clever idea, but not one that I think scales well with a bigger team. It would be better if manifests could go through code review, and be approved before going live.

This is the perfect use for <a href="https://code.google.com/p/gerrit/">Gerrit</a>: any proposed changes go into a pending queue, and are only merged after a review process.

In the Puppet workflow with Gerrit, committers push their proposed changes to the pending change area for <em>master</em>, and then they go through review.  Once approved, they are committed to <em>master</em>.  When ready to move on to another environment, they can be promoted -- by way of gerrit -- by merging to development, then quality, then production for example. Life cycle management for your puppet modules.

<a href="/static/images/2013/11/git_flow.jpg"><img src="/static/images/2013/11/git_flow.jpg" alt="git_flow" width="640" height="115" class="alignleft size-full wp-image-1018" /></a>

The diagram below shows how it works: a developer gets an authoritative copy of the repo, and makes some changes, but instead of committing back to the authoritative branch, it is committed to a special staging area.  The staged commit shows up in the Gerrit code review GUI.  Members of the team review the code, and provide any relevant feedback. Once the code gets a +2 vote, it's merged into the authoritative repo.  

<a href="/static/images/2013/11/gerrit.png"><img src="/static/images/2013/11/gerrit.png" alt="Figure 1" width="620" height="400" class="size-full wp-image-978" /></a>

When a change is merged, the change-merged hook is executed.  I've written <a href="https://github.com/stbenjam/puppet-gerrit-workflow">one that will automatically publish the puppet environment</a>.  Unfortunately we need this separate hook, because gerrit does not look at anything in the .git/hooks directory.

Now, an interesting thing about gerrit is that all of the reviewers do not need to the human.  Using the Gerrit Trigger for Jenkins, a staged commit can be tested, run through puppet-lint, or any other steps that are needed. The <a href="https://wiki.jenkins-ci.org/display/JENKINS/Gerrit+Trigger">Jenkins wiki</a> explains in more detail how it works.  Basically, Jenkins can submit a vote back based on it's results. Assuming the tests were successful, reviewer(s) can examine the proposed changes -- and once the final approval is given, it's deployed instantly to your puppetmaster.



