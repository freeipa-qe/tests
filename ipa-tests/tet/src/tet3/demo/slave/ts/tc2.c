/*
 *      SCCS:  @(#)tc2.c	1.2 (96/08/15) 
 *
 * (C) Copyright 1994 UniSoft Ltd., London, England
 *
 * All rights reserved.  No part of this source code may be reproduced,
 * stored in a retrieval system, or transmitted, in any form or by any
 * means, electronic, mechanical, photocopying, recording or otherwise,
 * except as stated in the end-user licence agreement, without the prior
 * permission of the copyright owners.
 */

#ifndef lint
static char sccsid[] = "@(#)tc2.c	1.2 (96/08/15) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)tc2.c	1.2 96/08/15 TETware release 3.7
NAME:		tc2.c
PRODUCT:	TETware
AUTHOR:		Denis McConalogue, UniSoft Ltd.
DATE CREATED:	October 1993

DESCRIPTION:
	demo test suite slave system test case 2

MODIFICATIONS:

************************************************************************/
#include <stdlib.h>
#include <tet_api.h>

void (*tet_startup)() = NULL, (*tet_cleanup)() = NULL;
void tp1();

struct tet_testlist tet_testlist[] = { {tp1,1}, {NULL,0} };

void tp1()
{
	tet_infoline("This is the second test case (tc2, slave)");

	tet_result(TET_FAIL);
}

