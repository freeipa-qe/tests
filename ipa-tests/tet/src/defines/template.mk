#
#      SCCS:  @(#)template.mk	1.17 (02/04/23) 
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
# SCCS:   	@(#)template.mk	1.17 02/04/23 TETware release 3.7
# NAME:		template.mk
# PRODUCT:	TETware
# AUTHOR:	Andrew Dingwall, UniSoft Ltd.
# DATE CREATED:	June 1992
#
# DESCRIPTION:
#	Template for the defines.mk file that contains common
#	machine-dependent definitions used in makefiles.
#	The defines.mk file is included in lower level makefiles.
#
#	Use this file to build your own defines.mk, which should be
#	installed in TET_ROOT/src.
#
#	Please refer to the section entitled "Preparing to build TETware"
#	in the TETware Installation Guide for UNIX Operating Systems
#	for instructions on how to use this file.
#
# MODIFICATIONS:
# 
#	Geoff Clare, UniSoft Limited, July-Oct 1996
#	Changes for TETWare.
#
#	Andrew Dingwall, UniSoft Ltd., August 1998
#	Enhanced support for building thread-safe API libraries.
#	Added support for building shared API libraries.
# 
#	Andrew Dingwall, UniSoft Ltd., August 1999
#	Added support for the Java API.
#
#	Andrew Dingwall, The Open Group, February 2002
#	Added support for the POSIX Shell API.
# 
# ************************************************************************


# In Distributed TETware, tccd can be started:
#	from /etc/inittab (SYSV systems)
#	from /etc/inetd (BSD4.3 style)
#	from /etc/rc (BSD4.2 style)
#	interactively by a user (not recommeded!)
#
# inittab systems should include -DINITTAB in DTET_CDEFS below
# inetd systems should include -DINETD in DTET_CDEFS below
# [ Not relevant for TETware-Lite ]

# TCCD specifies the name by which tccd is to be known; this should be in.tccd
# if you define INETD, otherwise it should be tccd
# [ Not used when building TETware-Lite ]
TCCD =


# ************************************************************************

# make utilities - these don't usually change
MAKE = make
SHELL = /bin/sh


# ************************************************************************

# sgs component definitions and flags
#
# TET and DTET defines; one of these is added to CDEFS in each compilation
#	TET_CDEFS are used to compile most source files
#	    these should include -D_POSIX_SOURCE 
#
#	DTET_CDEFS are used to compile source files which use non-POSIX
#	features, such as networking
#	    for example:
#	    inet:  DTET_CDEFS = -D_ALL_SOURCE -DINETD
#	    xti:   DTET_CDEFS = -D_ALL_SOURCE -DTCPTPI
#
#	On systems that conform to UNIX95,
#	-D_XOPEN_SOURCE -D_XOPEN_SOURCE_EXTENDED might be good feature
#	test macros to use.
#
#	On systems that conform to UNIX98, -D_XOPEN_SOURCE=500 might be
#	a good feature test macro to use.
#
TET_CDEFS =
DTET_CDEFS =

# CC - the name of the C compiler
CC = cc
#
# LD_R - the program that performs partial linking
LD_R = ld -r
#
# CDEFS and COPTS - options that are always passed to cc when compiling
# program and "ordinary" library files
# (i.e.: not thread-safe or shared libraries)
# CDEFS is used to specify -I, -D and -U options
# CDEFS always includes -I$(INC) -I$(DINC) (in that order)
# and usually defines NSIG (the highest signal number plus one)
# COPTS is used to specify other options (e.g.: -O)
CDEFS = -I$(INC) -I$(DINC) -DNSIG=NN
COPTS = -O
#
# LDFLAGS - options that are always passed to cc when linking
LDFLAGS =
#
# system libraries for inclusion at the end of the cc command line
# when building TETware programs
SYSLIBS =
#
# if your system's a.out format includes a .comment section that can be
# compressed by using mcs -c, set MCS to mcs; otherwise set MCS to @:
MCS = @:
#
# AR is the name of the archive library maintainer
AR = ar
#
# LORDER and TSORT are the names for lorder and tsort, used to order an archive
# library; if they don't exist on your system or don't work, set LORDER to echo
# and TSORT to cat
LORDER = lorder
TSORT = tsort
#
# if your system needs ranlib run after an archive library is updated,
# set RANLIB to ranlib; otherwise set RANLIB to @:
RANLIB = @:


# Support for Threads
#
# THR_COPTS is used instead of COPTS when compiling the thread API library.
# To disable thread support, set THR_COPTS = THREADS_NOT_SUPPORTED.
# For POSIX threads, include -DTET_POSIX_THREADS (default is UI threads).
THR_COPTS = THREADS_NOT_SUPPORTED
#
# TET and DTET defines used when compiling the thread-safe API library.
# these are used instead of TET_CDEFS and DTET_CDEFS
#
# TET_THR_CDEFS should normally include -D_POSIX_C_SOURCE=199506
# or -D_XOPEN_SOURCE=500 when building the thread-safe API library to
# use POSIX threads
TET_THR_CDEFS =
DTET_THR_CDEFS = $(DTET_CDEFS)


# Support for shared libraries
#
# SHLIB_COPTS is used in addition to COPTS / THR_COPTS when generating the
# object files that are to be put in a shared library.
# On many systems the option(s) specified here instructs the compiler
# to generate position-independent code.
# Set SHLIB_COPTS to SHLIB_NOT_SUPPORTED if shared libraries are not supported
# on your system or if you don't want to build the shared versions of the
# API libraries.
SHLIB_COPTS = SHLIB_NOT_SUPPORTED
#
# SHLIB_CC names the compiler that is used when generating the object files
# that are to be put in a shared library.
# Usually it is just $(CC) but it might be a shell script that generates
# lists of import and export functions as well as calling $(CC)
SHLIB_CC = $(CC)
#
# SHLIB_BUILD names the utility that builds a shared library from a set of
# object files.
# Often this utility is $(CC) invoked with special options, or it might be
# a shell script.
# It is invoked thus:
#	$(SHLIB_BUILD) -o library-name object-files ... $(SHLIB_BUILD_END)
SHLIB_BUILD =
SHLIB_BUILD_END =
#
# THRSHLIB_BUILD_END is used instead of SHLIB_BUILD_END when building
# a thread-safe shared library
THRSHLIB_BUILD_END =


# Support for C++
#
# C_PLUS - the name of the C++ compiler
# To disable C++ support, set C_PLUS = CPLUSPLUS_NOT_SUPPORTED.
C_PLUS = CPLUSPLUS_NOT_SUPPORTED
# C_SUFFIX - suffix for C++ source files
# (without an initial dot; e.g: C, cpp etc.)
C_SUFFIX =


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


# Source and object file suffixes that are understood by the sgs
# on this platform.
# Note that all these suffixes may include an initial dot - this convention
# permits an empty suffix to be specified.
# O - suffix that denotes an object file (e.g.: .obj or .o)
O =
# A - suffix that denotes an archive library (e.g.: .lib or .a)
A =
# E - suffix that denotes an executable file (e.g.: .exe or nothing)
E =
# SH - suffix that denotes an executable shell script (e.g.: .ksh or nothing)
# NOTE: must not be .sh, since this is used for shell source files
SH =
# SO - suffix that denotes a shared library (e.g.: .so, .sl, etc.)
SO =


# ************************************************************************

# Definitions for the xpg3 Shell API and TCM (xpg3sh).
# There is a shell script called src/sigtool which will help you
# generate these signal lists.
#
# standard signal numbers - change to correct numbers for your system
# SIGHUP, SIGINT, SIGQUIT, SIGILL, SIGABRT, SIGFPE, SIGPIPE, SIGALRM,
# SIGTERM, SIGUSR1, SIGUSR2, SIGTSTP, SIGCONT, SIGTTIN, SIGTTOU
# 
# Example: SH_STD_SIGNALS = 1 2 3 4 6 8 13 14 15 16 17 25 26 27 28
SH_STD_SIGNALS = 

# signals that are always unhandled - change for your system
# May need to include SIGSEGV and others if the shell can't trap them
# SIGKILL, SIGCHLD, SIGSTOP, (SIGSEGV, ...)
#
# Example: SH_SPEC_SIGNALS = 9 18 24 11
SH_SPEC_SIGNALS = 

# Highest shell signal number plus one.
# May need to be less than the value specified with -DNSIG in CDEFS
# if the shell can't trap higher signal numbers.
SH_NSIG = 

# Definitions for the Korn Shell API and TCM (ksh).
#
# The meanings of these variables are the same as for the corresponding
# variables used by the xpg3sh API.
# Usually the values used by the two APIs are the same.
# You only need to specify different values here if the Korn Shell is more
# (or less) capable than the xpg3 Shell on your system.
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

