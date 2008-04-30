/*
 *      SCCS:  @(#)fake.c	1.7 (99/09/02) 
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1992 X/Open Company Limited
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

#ifndef lint
static char sccsid[] = "@(#)fake.c	1.7 (99/09/02) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)fake.c	1.7 99/09/02 TETware release 3.7
NAME:		fake.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	fake server-specific functions for syncd

MODIFICATIONS:

************************************************************************/

#include <time.h>
#include "dtmac.h"
#include "dtmsg.h"
#include "ptab.h"
#include "error.h"
#include "server.h"

#ifdef NEEDsrcFile
static char srcFile[] = __FILE__;	/* file name for error reporting */
#endif

/*
**	tet_ss_connect() - fake connect routine for syncd
**
**	syncd is never a client, so never connects to other processes
*/

void tet_ss_connect(pp)
struct ptab *pp;
{
	error(0, "internal error - connect called", tet_r2a(&pp->pt_rid));
}

