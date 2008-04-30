/*
 *	SCCS: @(#)tccdstart.c	1.5 (98/09/01)
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1996 X/Open Company Limited
 *
 * All rights reserved.  No part of this source code may be reproduced,
 * stored in a retrieval system, or transmitted, in any form or by any
 * means, electronic, mechanical, photocopying, recording or otherwise,
 * except as stated in the end-user licence agreement, without the prior
 * permission of the copyright owners.
 * A copy of the end-user licence agreement is contained in the file
 * Licence which accompanies this distribution.
 * 
 * X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
 * the UK and other countries.
 */

#ifndef lint
static char sccsid[] = "@(#)tccdstart.c	1.5 (98/09/01) TET3 release 3.7";
static char *copyright[] = {
	"(C) Copyright 1996 X/Open Company Limited",
	"All rights reserved"
};
#endif

/************************************************************************

SCCS:   	@(#)tccdstart.c	1.5 98/09/01 TETware release 3.7
NAME:		tccdstart.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	October 1996

DESCRIPTION:
	inetd-like program used to launch tccd on WIN32 platforms

	on other platforms this program just prints a diagnostic and
	exits


MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., May 1997
	port to Windows 95

	Andrew Dingwall, UniSoft Ltd., July 1998
	Added support for shared API libraries.
	Changes to conform to UNIX98.
 

************************************************************************/

#include <stdio.h>


int main()
{
	static char *text[] = {
		"tccdstart is not used on this type of system.\n",
		"Please refer to the TETware Installation and User Guide",
		"for details on how to start tccd on your system."
	};

	char **tp;

	for (tp = text; tp < &text[sizeof text / sizeof text[0]]; tp++)
		(void) fprintf(stderr, "%s\n", *tp);

	return(1);
}


