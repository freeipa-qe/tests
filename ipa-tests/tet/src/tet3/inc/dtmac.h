/*
 *      SCCS:  @(#)dtmac.h	1.16 (03/03/26) 
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1992 X/Open Company Limited
 * (C) Copyright 1994 UniSoft Limited
 *
 * All rights reserved.  No part of this source code may be reproduced,
 * stored in a retrieval system, or transmitted, in any form or by any
 * means, electronic, mechanical, photocopying, recording or otherwise,
 * except as stated in the end-user licence agreement, without the prior
 * permission of the copyright owners.
 *
 * X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
 * the UK and other countries.
 */

/************************************************************************

SCCS:   	@(#)dtmac.h	1.16 03/03/26 TETware release 3.7
NAME:		dtmac.h
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	useful macros used in various parts of the system
	macros that interface to the trace subsystem

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., December 1993
	moved most of the non-posix band-aid stuff from individual
	source files to here

	Andrew Dingwall, UniSoft Ltd., September 1996
	added compatibility macros for the NT port

	Andrew Dingwall, UniSoft Ltd., March 1997
	added support for (WIN32-specific) tet_unlink()

	Andrew Dingwall, UniSoft Ltd., July 1997
	added support the MT DLL version of the C runtime support library
	on Win32 systems

	Andrew Dingwall, UniSoft Ltd., March 1998
	removed references to sys_errlist[] and sys_nerr since these
	symbols are no longer in the Single Unix Specification

	Andrew Dingwall, UniSoft Ltd., July 1998
	Added support for shared API libraries.
	Changed MAX() and MIN() to TET_MAX() and TET_MIN().

	Andrew Dingwall, UniSoft Ltd., July 1999
	moved the win32 shared library bandaid to a position before the
	compatibility macros so that compatibility functions can be
	declared as TET_IMPORT if necessary

	Andrew Dingwall, The Open Group, March 2003
	Added UTIME and UTIMBUF compatibility macros.


************************************************************************/

/*
**	macros that might be system-dependent
*/

/* SIG_T is the type for the return value of signal(),
   SIG_FUNC_T is the type for the function argument to signal() */
#ifdef SVR2
#  define SIG_T		int
#  define SIG_FUNC_T	void
#else
#  if defined(BSD42) || defined(BSD43)
#    define SIG_T	int
#    define SIG_FUNC_T	int
#  else
#    define SIG_T	void
#    define SIG_FUNC_T	void
# endif /* BSD */
#endif /* SVR2 */

/* define NOMKDIR if the system does not have the mkdir() and rmdir() system
	calls - see dtetlib/mkdir.c */
#ifdef SVR2
#  define NOMKDIR
#endif

/*
** decide what type of directory access method to use;
** these defines determine which include files are used
*/
#ifdef SVR2
#  define NDIR		/* include <ndir.h> */
#else
#  if defined(BSD42) || defined(BSD43) || defined(ultrix)
#    define SYSDIR	/* include <sys/dir.h> */
#  else
#      define DIRENT	/* default - include <dirent.h> */
#  endif /* BSD */
#endif /* SVR2 */

/* choose whether to include function declaration files (like <stdlib.h>)
	or declare non-int functions locally in each file */
#if defined(SVR2) || defined(BSD42) || defined(BSD43)
#  define LOCAL_FUNCTION_DECL
#endif

/*
**	function prototypes
**
**	we define PROTOTYPES if the compiler understands ANSI-style
**	function prototypes
**
**	if PROTOTYPES is defined, we assume that system header files
**	are protected against multiple inclusion as well
*/

#if defined(__STDC__) || defined(__cplusplus)
#  ifndef PROTOTYPES
#    define PROTOTYPES
#  endif
#endif

/* function prototype macro */
#ifdef PROTOTYPES
#  define PROTOLIST(list)	list
#else
#  define PROTOLIST(list)	()
#  define const
#endif


/*
**	Band-aid to enable a Win32 DLL to behave more like
**	a UNIX shared library, and for shared library implementations
**	that need import and export lists to be generated.
*/

/*
** When a shared API library is built, the API library has two parts;
** a SHARED part (libapi_s) and a STATIC part (libtcm_s).
** The static part mostly consists of the TCM object files that go in
** libapi when the static API library is built.
**
** If TET_SHLIB is defined it means that we are building a shared API library.
** If TET_SHLIB_SOURCE is defined it means that we are compiling code
** that goes in the a shared API library.
**
** TET_SHLIB is defined in the tcm*shlib makefiles.
** TET_SHLIB_SOURCE is defined in the api*shlib makefiles.
**
** TET_SHLIB_SOURCE implies TET_SHLIB
*/
#if defined(TET_SHLIB_SOURCE) && !defined(TET_SHLIB)
#  define TET_SHLIB
#endif


   /* not using shared libraries on a Win32 system */
#  define TET_IMPORT
#  define TET_EXPORT


#if !defined(TET_SHLIB_BUILD_SCRIPT) && !defined(TET_DYNLINK_SOURCE) && !defined(TET_DLCHECK_SOURCE)
#  define TET_EXPORT_FUNC(TYPE, NAME, ARGS) \
	TET_EXPORT extern TYPE NAME ARGS
#  define TET_EXPORT_FUNC_PTR(TYPE, NAME, ARGS) \
	TET_EXPORT extern TYPE (*NAME) ARGS
#  define TET_EXPORT_DATA(TYPE, NAME) \
	TET_EXPORT extern TYPE NAME
#  define TET_EXPORT_ARRAY(TYPE, NAME, DIM) \
	TET_EXPORT extern TYPE NAME DIM
#endif

#ifndef TET_SHLIB_BUILD_SCRIPT
#  define TET_IMPORT_FUNC(TYPE, NAME, ARGS) \
	TET_IMPORT extern TYPE NAME ARGS
#  define TET_IMPORT_FUNC_PTR(TYPE, NAME, ARGS) \
	TET_IMPORT extern TYPE (*NAME) ARGS
#  define TET_IMPORT_DATA(TYPE, NAME) \
	TET_IMPORT extern TYPE NAME
#  define TET_IMPORT_ARRAY(TYPE, NAME, DIM) \
	TET_IMPORT extern TYPE NAME DIM
#endif


/*
**	macros to provide access to UNIX-like system calls and library routines
**
**	each macro provides access to a function which is not part of
**	ANSI C, and thus may not be available on all platforms
**
**	a set of macros appears here for each API to which TETware is ported;
**	each set of compatibility macros also defines TET_COMPAT_MACROS
**	which is used to ensure that exactly one set of compatibility macros
**	is defined
**
**	note that the macros which appear here should only be used internally
**	by TETware and (in some cases) only provide sufficient functionality
**	for use by TETware routines
*/



/*
** UNIX-like systems - the default
**
** most of these functions are declared in <unistd.h>
*/
#ifndef TET_COMPAT_MACROS

#  define TET_COMPAT_MACROS

#  define ACCESS(A, B)		access((A), (B))
#  define CHDIR(A)		chdir((A))
#  define CHMOD(A, B)		chmod((A), (B))
#  define CLOSE(A)		close((A))
#  define CLOSEDIR(A)		closedir((A))
#  define ENVIRON		environ
#  define FCNTL_F_DUPFD(A, B)	fcntl((A), F_DUPFD, (B))
#  define FDOPEN(A, B)		fdopen((A), (B))
#  define FILENO(A)		fileno((A))
#  define FSTAT(A, B)		fstat((A), (B))
#  define GETCWD(A, B)		getcwd((A), (B))
#  define GETOPT(A, B, C)	getopt((A), (B), (C))
#  define GETPID()		getpid()
#  define KILL(A, B)		kill((A), (B))
#  define OPEN(A, B, C)		open((A), (B), (C))
#  define OPENDIR(A)		opendir((A))
#  define READ(A, B, C)		read((A), (B), (C))
#  define READDIR(A)		readdir((A))
#  define SLEEP(A)		((void) sleep(A))
#  define STAT(A, B)		stat((A), (B))
#  define STAT_ST		stat
#  define UNLINK(A)		unlink((A))
#  define UTIME(A, B)		utime((A), (B))
#  define UTIMBUF		utimbuf
#  define WRITE(A, B, C)	write((A), (B), (C))

   /* extra help for the OPEN() macro */
#  ifndef O_TEXT
#    define O_TEXT		0
#  endif
#  ifndef O_BINARY
#    define O_BINARY		0
#  endif
#  ifndef O_NOINHERIT
#    define O_NOINHERIT		0
#  endif

   /* extra help for the socket interface */
   typedef int SOCKET;
#  define INVALID_SOCKET	-1
#  define SOCKET_ERROR		-1
#  define SOCKET_ERRNO		errno
#  define CLEAR_SOCKET_ERRNO	errno = 0
#  define SOCKET_CLOSE(A)	close((A))
#  define SOCKET_FIOCLEX(A)	tet_fioclex((A))
#  define SOCKET_IOCTL(A, B, C)	ioctl((A), (B), (C))
#  define SOCKET_ECONNRESET	ECONNRESET
#  define SOCKET_EINPROGRESS	EINPROGRESS
#  define SOCKET_EINTR		EINTR
#  define SOCKET_EWOULDBLOCK	EWOULDBLOCK

#endif /* TET_COMPAT_MACROS */


/*
**	macros to classify path names
*/

/* macros to identify a directory separator character */
#define ispcdirsep(x)		((x) == '/' || (x) == '\\')
#define isunixdirsep(x)		((x) == '/')

#  define isdirsep(x)		isunixdirsep(x)

/*
** macros to clasify path names on PC platforms
**
** these valid on all platforms
*/

/* path starts with a drive specifier */
#define isdrvspec(x)	(isalpha(*(x)) && *((x) + 1) == ':')

/* path is an absolute path name on the current drive */
#define isabsoncur(x)	ispcdirsep(*(x))

/* path is an absolute path name on a specified drive */
#define isabsondrv(x)	(isdrvspec(x) && isabsoncur((x) + 2))

/* these valid on PCs */


/* macro to identify an absolute path name on the local machine */
#  define isabspathloc(x)	isunixdirsep(*(x))

/*
** macro to identify an absolute path name on a remote machine which 
** could be a UNIX or a PC platform
*/
#define isabspathrem(x)		(isabsondrv(x) || isunixdirsep(*(x)))



/*
**	macros that are common to all systems
*/

/* define TESTING here if it's not on the cc command line */
#ifndef TESTING
#  define TESTING 0
#endif

/* maximimum and minimum macros */
#define TET_MAX(a, b)	((a) > (b) ? (a) : (b))
#define TET_MIN(a, b)	((a) < (b) ? (a) : (b))

/* maximum length for a path name - needs to be system-independent */
#define MAXPATH		1024

/* maximum length for a system name as found in the DTET systems file */
#define SNAMELEN	32


/*
**	band-aid for non-posix systems
*/

#if defined(SVR2) || defined(BSD42) || defined(BSD43)
   typedef int mode_t;
   typedef int size_t;
   typedef int pid_t;
   typedef int uid_t;
#endif /* SVR2 || BSD4x */

#ifdef S_IFMT	/* non-posix <sys/stat.h> is included */
#  ifndef S_IRUSR
#    define S_IRUSR	0400
#    define S_IWUSR 0200
#    define S_IXUSR 0100
#    define S_IRGRP	040
#    define S_IWGRP	020
#    define S_IXGRP	010
#    define S_IROTH	04
#    define S_IWOTH	02
#    define S_IXOTH	01
#    define S_IRWXU (S_IRUSR | S_IWUSR | S_IXUSR)
#    define S_IRWXG (S_IRGRP | S_IWGRP | S_IXGRP)
#    define S_IRWXO (S_IROTH | S_IWOTH | S_IXOTH)
#  endif /* S_IRUSR */
#  ifndef S_ISDIR
#    define S_ISDIR(m)	(((m) & S_IFMT) == (S_IFDIR))
#  endif /* S_ISDIR */
#  ifndef S_ISREG
#    define S_ISREG(m)	(((m) & S_IFMT) == (S_IFREG))
#  endif /* S_ISREG */
#  ifndef S_ISFIFO
#    define S_ISFIFO(m)	(((m) & S_IFMT) == (S_IFIFO))
#  endif /* S_ISFIFO */
#endif /* S_IFMT */

#if defined(stdout) && !defined(SEEK_SET)	/* non-posix <stdio.h> */
#  define SEEK_SET	0
#  define SEEK_CUR	1
#  define SEEK_END	2
#endif

/*
**	trace macros
*/

#ifdef NOTRACE

#  define TRACE1(flag, level, s1)
#  define TRACE2(flag, level, s1, s2)
#  define TRACE3(flag, level, s1, s2, s3)
#  define TRACE4(flag, level, s1, s2, s3, s4)
#  define TRACE5(flag, level, s1, s2, s3, s4, s5)
#  define TRACE6(flag, level, s1, s2, s3, s4, s5, s6)
#  define TDUMP(flag, level, from, count, title)
#  define BUFCHK(bpp, lp, newlen)	tet_bufchk(bpp, lp, newlen)

#else /* NOTRACE */

#  define TRACE1(flag, level, s1)	\
	TRACE2(flag, level, s1, (char *) 0)

#  define TRACE2(flag, level, s1, s2) \
	TRACE3(flag, level, s1, s2, (char *) 0)

#  define TRACE3(flag, level, s1, s2, s3) \
	TRACE4(flag, level, s1, s2, s3, (char *) 0)

#  define TRACE4(flag, level, s1, s2, s3, s4) \
	TRACE5(flag, level, s1, s2, s3, s4, (char *) 0)

#  define TRACE5(flag, level, s1, s2, s3, s4, s5) \
	TRACE6(flag, level, s1, s2, s3, s4, s5, (char *) 0)

#  define TRACE6(flag, level, s1, s2, s3, s4, s5, s6) \
	if ((flag) >= (level)) tet_trace(s1, s2, s3, s4, s5, s6); else

#  define TDUMP(flag, level, from, count, title) \
	if ((flag) >= (level)) tet_tdump(from, count, title); else

#  define BUFCHK(bpp, lp, newlen) \
	tet_buftrace(bpp, lp, newlen, srcFile, __LINE__)

#  ifndef NEEDsrcFile
#    define NEEDsrcFile
#  endif


   /*
   **	declarations of extern functions and data items
   */

   /* trace flag declarations */
   TET_IMPORT_DATA(int, tet_Tbuf);
   TET_IMPORT_DATA(int, tet_Ttcm);
   extern int tet_Ttcc, tet_Ttrace, tet_Tscen, tet_Texec;
#  ifndef TET_LITE	/* -START-LITE-CUT- */
      extern int tet_Tio, tet_Tloop, tet_Tserv, tet_Tsyncd, tet_Ttccd,
	tet_Txresd;
#  endif /* !TET_LITE */	/* -END-LITE-CUT- */

   /* trace subsystem function definitions */
   extern void tet_tdump PROTOLIST((char *, int, char *));
   TET_IMPORT_FUNC(void, tet_tfclear, PROTOLIST((void)));
   TET_IMPORT_FUNC(void, tet_trace,
	PROTOLIST((char *, char *, char *, char *, char *, char *)));
   extern char **tet_traceargs PROTOLIST((int, char **));
   TET_IMPORT_FUNC(void, tet_traceinit, PROTOLIST((int, char **)));

#endif	/* NOTRACE */

