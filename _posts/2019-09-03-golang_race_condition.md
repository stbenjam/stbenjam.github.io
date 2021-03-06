---
layout: post
title: "golang: finding a race condition in Docker"
date: 2019-09-03 14:02:00
categories: technical
comments: true
---

In OpenShift's client utilities, we use some vendored Docker code to
extract data from a container image. Several images could be extracted
concurrently, and we were running into an issue where only on RHEL 8
clients, occassionally a user would see a panic:

```
panic: runtime error: slice bounds out of range

goroutine 163 [running]:
bufio.(*Reader).fill(0xc000f35c80)
        /opt/rh/go-toolset-1.12/root/usr/lib/go-toolset-1.12-golang/src/bufio/bufio.go:89 +0x211
```

We didn't know why we only saw it on RHEL 8 clients, and why it only
happened *sometimes*. I wanted a better traceback than the original bug
report gave us, and maybe a coredump so I could poke around in
[gdb](https://golang.org/doc/gdb).  To be honest, I didn't really know
what I'd be looking for in gdb. I'd only ever used it with C, and even
in C, I'm generally a printf debuggerer.

However, I hadn't been able to reproduce the problem myself, so I wanted
to get as much information as I could.

We added `export GOTRACEBACK=crash` to our development scripts, and
waited until someone saw it again.  It wasn't too much longer when we
got a report of it again, and I was able to see a much longer stack
trace that showed me all of the running goroutines, as well as getting a
coredump.

It looked like code in go itself was reading past the end of it's own
buffer: what? Was there a bug in go? I started researching this some
more, and I was still a bit lost, until I stumbled upon an entry in the
longer stack trace that pointed me to Docker's code using a pool of
buffers.

Docker maintains a pool of `*bufio.Reader` to reduce memory usage.  If
these were being recycled, and some previous holder of it tried to write
to it after giving it back, and someone else got a hold of it very
quickly -- this all sounded somewhat familiar, and reminded me of my
Operating System's class. Was this a race condition?

Identifying *what kind of problem* I was dealing with made things a lot
easier.  In retrospect, maybe I should've realized it was a race
condition sooner, but now that I knew what it was, I wanted to know how
people might uncover a race condition in golang.

Go [includes tools for detecting these cases](https://golang.org/doc/articles/race_detector.html),
by simply building or running your go code with the `-race` argument. After doing that,
and running locally, my program exited successfully with no warnings
about any kind of race condition. Theoretically, this tooling was supposed to identify
the potential race even if it wasn't causing a panic.

I even tried it on a RHEL 8 virtual machine, just like the reporters of the bugs were using.
Nothing.

As a last resort, I asked a coworker if I could experiment in an environment
that he seemed to encounter the problem once a day or so. I wrote a
[script](https://gist.github.com/stbenjam/9305bb31db4c1754e3e84ddcd354ebbe) that
would run the command over and over again, hoping that it crashed. I used the binary
that had been built with the `-race` flag.

Sure enough, on his system, go enthusiastically reported **"WARNING: DATA
RACE"**, with a traceback telling me exactly where.

```
WARNING: DATA RACE
Write at 0x00c00115b320 by goroutine 94:
  bufio.(*Reader).reset()
      /usr/local/go/src/bufio/bufio.go:75 +0xe0
  bufio.(*Reader).Reset()
      /usr/local/go/src/bufio/bufio.go:71 +0xd1
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/pools.(*BufioReaderPool).Put()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/pools/pools.go:54 +0x5b
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/pools.(*BufioReaderPool).NewReadCloserWrapper.func1()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/pools/pools.go:93 +0x140
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/ioutils.(*ReadCloserWrapper).Close()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/ioutils/readers.go:20 +0x5e
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive.wrapReadCloser.func1()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive/archive.go:180 +0x80
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/ioutils.(*ReadCloserWrapper).Close()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/ioutils/readers.go:20 +0x5e
  github.com/openshift/oc/pkg/cli/image/extract.layerByEntry()
      /go/src/github.com/openshift/oc/pkg/cli/image/extract/extract.go:524 +0x975
  github.com/openshift/oc/pkg/cli/image/extract.(*Options).Run.func1.1.2()
      /go/src/github.com/openshift/oc/pkg/cli/image/extract/extract.go:455 +0xa0f
  github.com/openshift/oc/pkg/cli/image/extract.(*Options).Run.func1.1()
      /go/src/github.com/openshift/oc/pkg/cli/image/extract/extract.go:467 +0x31f8
  github.com/openshift/oc/pkg/cli/image/workqueue.(*worker).Try.func1()
      /go/src/github.com/openshift/oc/pkg/cli/image/workqueue/workqueue.go:137 +0x6d
  github.com/openshift/oc/pkg/cli/image/workqueue.(*workQueue).run.func1()
      /go/src/github.com/openshift/oc/pkg/cli/image/workqueue/workqueue.go:51 +0x35d

Previous read at 0x00c00115b320 by goroutine 8:
  bufio.(*Reader).writeBuf()
      /usr/local/go/src/bufio/bufio.go:525 +0xc7
  bufio.(*Reader).WriteTo()
      /usr/local/go/src/bufio/bufio.go:506 +0x5e1
  io.copyBuffer()
      /usr/local/go/src/io/io.go:384 +0x13c
  io.Copy()
      /usr/local/go/src/io/io.go:364 +0x10a
  os/exec.(*Cmd).stdin.func1()
      /usr/local/go/src/os/exec/exec.go:243 +0xfa
  os/exec.(*Cmd).Start.func1()
      /usr/local/go/src/os/exec/exec.go:409 +0x3d

Goroutine 94 (running) created at:
  github.com/openshift/oc/pkg/cli/image/workqueue.(*workQueue).run()
      /go/src/github.com/openshift/oc/pkg/cli/image/workqueue/workqueue.go:43 +0xd8

Goroutine 8 (running) created at:
  os/exec.(*Cmd).Start()
      /usr/local/go/src/os/exec/exec.go:408 +0x16c2
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive.cmdStream()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive/archive.go:1224 +0x243
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive.gzDecompress()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive/archive.go:174 +0x52e
  github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive.DecompressStream()
      /go/src/github.com/openshift/oc/vendor/github.com/docker/docker/pkg/archive/archive.go:207 +0x806
  github.com/openshift/oc/pkg/cli/image/extract.layerByEntry()
      /go/src/github.com/openshift/oc/pkg/cli/image/extract/extract.go:486 +0xa1
  github.com/openshift/oc/pkg/cli/image/extract.(*Options).Run.func1.1.2()
      /go/src/github.com/openshift/oc/pkg/cli/image/extract/extract.go:455 +0xa0f
  github.com/openshift/oc/pkg/cli/image/extract.(*Options).Run.func1.1()
      /go/src/github.com/openshift/oc/pkg/cli/image/extract/extract.go:467 +0x31f8
  github.com/openshift/oc/pkg/cli/image/workqueue.(*worker).Try.func1()
      /go/src/github.com/openshift/oc/pkg/cli/image/workqueue/workqueue.go:137 +0x6d
  github.com/openshift/oc/pkg/cli/image/workqueue.(*workQueue).run.func1()
      /go/src/github.com/openshift/oc/pkg/cli/image/workqueue/workqueue.go:51 +0x35d
==================
```

Ok: why did his system do it and not mine? After examining the traceback, I noticed that this
was happening in the code that Docker uses to decompress a stream of compressed data. And in
that code for gzipped files, it can use the native Golang gzip library, or shell out to `unpigz`
which is a super fast, parallel utility. `unpgiz` was not present on any of my test systems; however
it was there on his. Installing the package on my server instantly reproduced the problem.

What was different? The code running `unpigz` was using one of those shared buffers I mentioned
earlier. There was a case where the context for a command was cancelled, and the buffer was
returned to the pool. However, with contexts and CommandContext in Go,
merely cancelling the context does not guarantee the command is fully done. You also need to wait for
`cmd.Wait()` to finish before returning any buffers to the pool.
Writing a [fix](https://github.com/moby/moby/pull/39860) that ensured that happened resolved our problem.
