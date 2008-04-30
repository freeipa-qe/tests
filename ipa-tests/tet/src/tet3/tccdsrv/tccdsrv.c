/*
 *	SCCS: @(#)tccdsrv.c	1.1 (00/09/05)
 *
 *	UniSoft Ltd., London, England
 *
 * Copyright (c) 2000 The Open Group
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
 ************************************************************************
 *
 * The following copyright applies to a small portion of this code:
 *
 * Copyright 1990, 1991, 1992 by the Massachusetts Institute of Technology and
 * UniSoft Group Limited.
 * 
 * Permission to use, copy, modify, distribute, and sell this software and
 * its documentation for any purpose is hereby granted without fee,
 * provided that the above copyright notice appear in all copies and that
 * both that copyright notice and this permission notice appear in
 * supporting documentation, and that the names of MIT and UniSoft not be
 * used in advertising or publicity pertaining to distribution of the
 * software without specific, written prior permission.  MIT and UniSoft
 * make no representations about the suitability of this software for any
 * purpose.  It is provided "as is" without express or implied warranty.
 *
 * $XConsortium: getopt.c,v 1.2 92/07/01 11:59:04 rws Exp $
 */

#ifndef lint
static char sccsid[] = "@(#)tccdsrv.c	1.1 (00/09/05) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)tccdsrv.c	1.1 00/09/05 TETware release 3.7
NAME:		tccdsrv.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	July 2000

DESCRIPTION:
	tccdsrv is the Windows NT service equivalent to tccdstart.
	It is a multi-threaded program and does not use any of the
	TETware header or library files.

MODIFICATIONS:

************************************************************************/

#include <stdio.h>


int main()
{
	static char *text[] = {
		"tccdsrv is not used on this type of system.\n",
		"Please refer to the TETware Installation and User Guide",
		"for details on how to start tccd on your system."
	};

	char **tp;

	for (tp = text; tp < &text[sizeof text / sizeof text[0]]; tp++)
		(void) fprintf(stderr, "%s\n", *tp);

	return(1);
}


