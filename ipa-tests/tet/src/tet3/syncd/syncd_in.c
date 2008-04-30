/*
 *      SCCS:  @(#)syncd_in.c	1.7 (99/09/02) 
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
static char sccsid[] = "@(#)syncd_in.c	1.7 (99/09/02) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)syncd_in.c	1.7 99/09/02 TETware release 3.7
NAME:		syncd_in.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	server-specific functions for syncd INET version

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., November 1993
	added transport-specific argument processing function


************************************************************************/


#include <stdlib.h>
#include <time.h>
#include <sys/types.h>
#  include <netinet/in.h>
#include "dtmac.h"
#include "dtmsg.h"
#include "ptab.h"
#include "error.h"
#include "server_in.h"
#include "inetlib_in.h"

#ifdef NEEDsrcFile
static char srcFile[] = __FILE__;	/* file name for error reporting */
#endif

/* socket on which to listen */
SOCKET tet_listen_sd = 0;

/*
**	tet_ss_tsaccept() - server-specific accept() processing
*/

void tet_ss_tsaccept()
{
	/* accept the connection unless we are closing down */
	if (tet_listen_sd != INVALID_SOCKET)
		tet_ts_accept(tet_listen_sd);
}

/*
**	tet_ss_tsafteraccept() - server-specific things to do after an accept()
*/

int tet_ss_tsafteraccept(pp)
struct ptab *pp;
{
	/* establish non-blocking i/o on the connection */
	return(tet_ts_nbio(pp));
}

/*
**	ss_tsinitb4fork() - syncd transport-specific initialisation
*/

void ss_tsinitb4fork()
{

	/* arrange to accept incoming connections */
	tet_ts_listen(tet_listen_sd);
}

/*
**	ss_tsargproc() - syncd transport-specific command-line
**		argument processing
**
**	return 0 if only firstarg was used or 1 if both args were used
*/

int ss_tsargproc(firstarg, nextarg)
char *firstarg, *nextarg;
{
	register int rc = 0;

	switch (*(firstarg + 1)) {
	default:
		fatal(0, "unknown option:", firstarg);
		/* NOTREACHED */
	}

	return(rc);
}

