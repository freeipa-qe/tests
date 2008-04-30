/*
 *	SCCS: @(#)dynlink.c	1.2 (99/09/03)
 *
 *	UniSoft Ltd., London, England
 *
 * Copyright (c) 1998 The Open Group
 * All rights reserved.
 *
 * No part of this source code may be reproduced, stored in a retrieval
 * system, or transmitted, in any form or by any means, electronic,
 * mechanical, photocopying, recording or otherwise, except as stated
 * in the end-user licence agreement, without the prior permission of
 * the copyright owners.
 * A copy of the end-user licence agreement is contained in the file
 * Licence which accompanies this distribution.
 * 
 * Motif, OSF/1, UNIX and the "X" device are registered trademarks and
 * IT DialTone and The Open Group are trademarks of The Open Group in
 * the US and other countries.
 *
 * X/Open is a trademark of X/Open Company Limited in the UK and other
 * countries.
 *
 */

#ifndef lint
static char sccsid_dynlink[] = "@(#)dynlink.c	1.2 (99/09/03) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)dynlink.c	1.2 99/09/03 TETware release 3.7
NAME:		dynlink.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	July 1998

DESCRIPTION:
	this is a simple dynamic linker for use when building a test case
	to use a shared API library on a Win32 system

	the dynamic linker is in two parts:

		tet_w32dynlink() resides in the main program
		tet_w32dlcheck() resides in the shared API library

	tet_w32dynlink() performs the dynamic linking
	tet_w32dlcheck() ensures that none of the pointers have been missed

	see the comment in dtmac.h for an overview of how this works


	no calls to TETware library functions are allowed from this file

MODIFICATIONS:

	Andrew Dingwall, UniSoft Ltd., July 1999
	moved TCM code out of the API library

************************************************************************/

/*
** This file is a component of the TCM (tcm.o) and/or one of the child
** process controllers (tcmchild.o and tcmrem.o).
** On UNIX systems, these .o files are built using ld -r.
** There is no equivalent to ld -r in MSVC, so on Win32 systems each .c
** file is #included in a scratch .c or .cpp file and a single object
** file built from that.
**
** This imposes some restictions on the contents of this file:
**
**	+ Since this file might be included in a C++ program, all
**	  functions must have both ANSI C and common C definitions.
**
**	+ The only .h file that may appear in this file is tcmhdrs.h;
**	  all other .h files that are needed must be #included in there.
**
**	+ The scope of static variables and functions encompasses all
**	  the source files, not just this file.
**	  So all static variables and functions must have unique names.
*/


/* TET_SHLIB_SOURCE implies TET_SHLIB */
#if defined(TET_SHLIB_SOURCE) && !defined(TET_SHLIB)
#  define TET_SHLIB
#endif


int tet_dynlink_c_not_used;


