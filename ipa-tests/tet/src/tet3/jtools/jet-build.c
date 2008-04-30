/*
 *	SCCS: @(#)jet-build.c	1.1 (99/09/02)
 *
 *	UniSoft Ltd., London, England
 *
 * Copyright (c) 1999 The Open Group
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
static char sccsid[] = "@(#)jet-build.c	1.1 (99/09/02) TET3 release 3.7";
#endif

/************************************************************************

SCCS:		@(#)jet-build.c	1.1 99/09/02 TETware release 3.7
NAME:		jet-build.c
PRODUCT:	TETware
AUTHOR:		(From JETPack sources) Matthew Hails, UniSoft Ltd.
DATE CREATED:	9 July 1999

DESCRIPTION:
	Build tool for TETware Java API. Executes java compiler with
	the appropriate environment.

************************************************************************/

#include <stdlib.h>
#include "jtools.h"

int
main(int argc, char** argv)
{
	jt_tool("javac", OP_SETCLASSPATH|OP_SWAPDIRSEP, argc, argv, ".java");
	return EXIT_SUCCESS;
}
