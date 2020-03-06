---
layout: post
title:  Tarbombs considered harmful
date:   2020-03-05 19:59:00
tags:   technical
author: "Stephen Benjamin"
---

So, one day you hear about this great new open source project, and visit
the company's web site and download the latest version of their software
`tofu-wonder.tar.gz`, and extract it in your home directory:

```
$ tar xvf tofu-wonder.tar.gz
.config/
.config/server.xml
.config/database.xml
README.txt
LICENSE.txt
tofu-wonder
001.dat
002.dat
003.dat
004.dat
005.dat
[...]
943.dat
```

You just got tarbombed. In older versions of tar, tarballs could even contain
absolute paths and potentially overwrite existing files on your file system.
These days, most versions of tar prevent this unless explicitly allowed,
so the worst that happens is a particular tar archive litters it's files
in whatever unfortunate directory you were in when you extracted it.
Have fun cleaning that up.

Ok - so how to avoid it? I now include this line in my .zshrc:

```
export TAR_OPTIONS="--one-top-level"
```

This option extracts all files into a directory named by the basename.
In the example above, it'd now look like this:

```
$ tar xvf tofu-wonder.tar.gz
tofu-wonder/.config/
tofu-wonder/.config/server.xml
tofu-wonder/.config/database.xml
tofu-wonder/README.txt
tofu-wonder/LICENSE.txt
tofu-wonder/tofu-wonder
tofu-wonder/001.dat
tofu-wonder/002.dat
tofu-wonder/003.dat
tofu-wonder/004.dat
tofu-wonder/005.dat
[...]
tofu-wonder/943.dat
```

Perfect! But, it's better not to make users do this. The first way to
prevent this is to include the top-level directory when you're creating
a tarball:

```
tar czvf tofu-wonder.tar.gz tofu-wonder/
```

Another option is to use transform and replace `.` with something else:

```
tar czvf tofu-wonder.tar.gz --transform "s?^\.?tofu-wonder-0.1.1?"  .
```
