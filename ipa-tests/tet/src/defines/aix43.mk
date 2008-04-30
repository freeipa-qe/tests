#
#      SCCS:  @(#)aix43.mk	1.4 (02/08/07)
#
#	UniSoft Ltd., London, England
#
# (C) Copyright 1992 X/Open Company Limited
#
# All rights reserved.  No part of this source code may be reproduced,
# stored in a retrieval system, or transmitted, in any form or by any
# means, electronic, mechanical, photocopying, recording or otherwise,
# except as stated in the end-user licence agreement, without the prior
# permission of the copyright owners.
#
# X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
# the UK and other countries.
#
#
# ************************************************************************
#
# SCCS:   	@(#)aix43.mk	1.4 02/08/07 TETware release 3.7
# NAME:		aix43.mk
# PRODUCT:	TETware
# AUTHOR:	Andrew Dingwall, UniSoft Ltd.
# DATE CREATED:	July 1998
#
# DESCRIPTION:
#	common machine-dependent definitions used in makefiles
#	this file is included in lower level makefiles
#
#	this one for aix4.3 on the RS6000 using sockets and inetd
#	POSIX threads supported
#
# MODIFICATIONS:
# 
#	Andrew Dingwall, UniSoft Ltd., August 1999
#	Added support for the Java API.
# 
#	Andrew Dingwall, The Open Group, February 2002
#	Added support for the POSIX Shell API.
#
#	Andrew Dingwall, The Open Group, August 2002
#	Removed -O from COPTS because the AIX 4.3 compiler generates
#	faulty code on certain hardware.
#	We don't use lorder/tsort any more because some versions of
#	lorder on AIX 4.3 produce no output when presented with a
#	single input file argument.
# 
# ************************************************************************

# tccd can be started:
#	from /etc/inittab (SYSV systems)
#	from /etc/inetd (BSD4.3 style)
#	from /etc/rc (BSD4.2 style)
#	interactively by a user
#
# inittab systems should include -DINITTAB in DTET_CDEFS below
# inetd systems should include -DINETD in DTET_CDEFS below
# [ Not relevant for TETware-Lite ]

# TCCD specifies the name by which tccd is to be known; this should be in.tccd
# if you define INETD, otherwise it should be tccd
# [ Not used when building TETware-Lite ]
TCCD = in.tccd

# make utilities - these don't usually change
MAKE = make
SHELL = /bin/sh

# TET and DTET defines; one of these is added to CDEFS in each compilation
#	TET_CDEFS are used to compile most source files
#	    these should include -D_POSIX_SOURCE 
#	    you may want to define TET_SIG_IGNORE and TET_SIG_LEAVE here
#
#	DTET_CDEFS are used to compile source files which use non-POSIX
#	features, such as networking and threads
#	    for example:
#	    inet:  DTET_CDEFS = -D_ALL_SOURCE -DINETD
#	    xti:   DTET_CDEFS = -D_ALL_SOURCE -DTCPTPI
#
TET_CDEFS = -D_POSIX_SOURCE
DTET_CDEFS = -D_XOPEN_SOURCE=500 -DINETD
TET_THR_CDEFS = -D_XOPEN_SOURCE=500
DTET_THR_CDEFS = -D_XOPEN_SOURCE=500 -DINETD

# sgs component definitions and flags
# CC - the name of the C compiler
CC = c89
# LD_R - the program that performs partial linking
LD_R = ld -r
# CDEFS may be passed to lint and cc, COPTS to cc only
# CDEFS usually defines NSIG (the highest signal number plus one)
CDEFS = -I$(INC) -I$(DINC) -DNSIG=64
COPTS =
# THR_COPTS is used instead of COPTS when compiling the thread API library.
# To disable thread support, set THR_COPTS = THREADS_NOT_SUPPORTED.
# For POSIX threads, include -DTET_POSIX_THREADS (default is UI threads).
THR_COPTS = $(COPTS) -DTET_POSIX_THREADS -D_THREAD_SAFE
# LDFLAGS - loader flags used by make's built-in rules
LDFLAGS =
# C_PLUS - the name of the C++ compiler
# To disable C++ support, set C_PLUS = CPLUSPLUS_NOT_SUPPORTED.
C_PLUS = CPLUSPLUS_NOT_SUPPORTED
# C_SUFFIX - suffix for C++ source files
C_SUFFIX = C
# if your system's a.out format includes a .comment section that can be
# compressed by using mcs -c, set MCS to mcs; otherwise set MCS to @:
MCS = @:
# AR is the name of the archive library maintainer
AR = ar
# LORDER and TSORT are the names for lorder and tsort, used to order an archive
# library; if they don't exist on your system or don't work, set LORDER to echo
# and TSORT to cat
LORDER = echo
TSORT = cat
# if your system needs ranlib run after an archive library is updated,
# set RANLIB to ranlib; otherwise set RANLIB to @:
RANLIB = @:

# Source and object file suffixes that are understood by the sgs
# on this platform.
# Note that all these suffixes may include an initial dot - this convention
# permits an empty suffix to be specified.
# O - suffix that denotes an object file
O = .o
# A - suffix that denotes an archive library
A = .a
# E - suffix that denotes an executable file
E =
# SH - suffix that denotes an executable shell script
SH =
# SO - suffix that denotes a shared library
SO = .a

# support for shared libraries
SHLIB_COPTS =
SHLIB_CC = CC=$(CC) sh -x ../bin/symbuild.sh
SHLIB_BUILD = sh ../bin/aix43_shlib_build.sh
SHLIB_BUILD_END = $(SYSLIBS)
THRSHLIB_BUILD_END = $(SHLIB_BUILD_END) -lpthread

# system libraries for inclusion at the end of cc command line
SYSLIBS =

# support for Java
#
# JAVA_CDEFS is used in addition to TET_CDEFS/DTET_CDEFS when compiling
# the Java API.
# It is normally set to -Ipath-to-jdk-include-directory
# and includes a list of signals that the TCM should leave alone.
# Set JAVA_CDEFS to JAVA_NOT_SUPPORTED if Java is not supported on your
# system or if you don't want to build the Java API.
# NOTE that the Java API is only supported on certain platforms - see the
# Installation Guide and/or the Release Notes for details.
JAVA_CDEFS = JAVA_NOT_SUPPORTED
#
# JAVA_COPTS is used in addition to COPTS when compiling the Java API.
JAVA_COPTS = $(SHLIB_COPTS)


# Definitions for xpg3sh API and TCM
#
# standard signal numbers - change to correct numbers for your system
# SIGHUP, SIGINT, SIGQUIT, SIGILL, SIGABRT, SIGFPE, SIGPIPE, SIGALRM,
# SIGTERM, SIGUSR1, SIGUSR2, SIGTSTP, SIGCONT, SIGTTIN, SIGTTOU
SH_STD_SIGNALS = 1 2 3 4 6 8 13 14 15 30 31 18 19 21 22

# signals that are always unhandled - change for your system
# May need to include SIGSEGV and others if the shell can't trap them
# SIGKILL, SIGCHLD, SIGSTOP, (SIGSEGV, ...)
SH_SPEC_SIGNALS = 9 20 17 11

# highest shell signal number plus one
# May need to be less than the value specified with -DNSIG in CDEFS
# if the shell can't trap higher signal numbers
SH_NSIG = 64

# Definitions for ksh API and TCM
KSH_STD_SIGNALS = $(SH_STD_SIGNALS)
KSH_SPEC_SIGNALS = $(SH_SPEC_SIGNALS)
KSH_NSIG = $(SH_NSIG)

# Definitions for the POSIX Shell API and TCM (posix_sh).
#
# The meanings of these variables are the same as for the corresponding
# variables used by the Korn Shell API.
# Usually the values used by the two APIs are the same.
# You only need to specify different values here if the POSIX Shell is more
# (or less) capable than the Korn Shell on your system.
PSH_STD_SIGNALS = $(KSH_STD_SIGNALS)
PSH_SPEC_SIGNALS = $(KSH_SPEC_SIGNALS)
PSH_NSIG = $(KSH_NSIG)

