/*
 *	SCCS: @(#)exec.c	1.5 (02/01/18)
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
static char sccsid[] = "@(#)exec.c	1.5 (02/01/18) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)exec.c	1.5 02/01/18 TETware release 3.7
NAME:		exec.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	August 1996

DESCRIPTION:
	test case execution functions

MODIFICATIONS:

************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <errno.h>
#include "dtmac.h"
#include "error.h"
#include "ltoa.h"
#include "servlib.h"
#include "config.h"
#include "systab.h"
#include "scentab.h"
#include "proctab.h"
#include "tcc.h"
#include "tcclib.h"

#ifdef NEEDsrcFile
static char srcFile[] = __FILE__;	/* file name for error reporting */
#endif


/*
**	tcc_texec() - execute a test case on the specified system
*/

long tcc_texec(prp, path, argv, tcdir, outfile)
struct proctab *prp;
char *path, **argv, *tcdir, *outfile;
{
	static char fmt[] = "TET_ACTIVITY=%d";
#ifdef TET_LITE	/* -LITE-CUT-LINE- */
	static
#endif /* TET_LITE */	/* -LITE-CUT-LINE- */
		char buf[sizeof fmt + LNUMSZ];
	struct systab *sp;
	long remid;
#ifdef TET_LITE	/* -LITE-CUT-LINE- */
	int err, pid;
#endif /* TET_LITE */	/* -LITE-CUT-LINE- */
#ifndef NOTRACE
	char **ap;
#endif

	ASSERT_LITE(*prp->pr_sys == 0);

	/*
	** put TET_ACTIVITY into the environment for the exec
	** if it is not already there
	*/
	sp = syfind(*prp->pr_sys);
	ASSERT(sp);
	if (sp->sy_activity != prp->pr_activity) {
		(void) sprintf(buf, fmt, prp->pr_activity);
		TRACE3(tet_Ttcc, 6, "putenv \"%s\" on system %s",
			buf, tet_i2a(*prp->pr_sys));
		if (tcc_putenv(*prp->pr_sys, buf) < 0) {
			prperror(prp, *prp->pr_sys, tet_tcerrno,
				"tcc_putenv(TET_ACTIVITY) failed", (char *) 0);
			return(-1L);
		}
		sp->sy_activity = prp->pr_activity;
	}

	/* change to the test case directory */
	if (sychdir(sp, tcdir) < 0) {
		prperror(prp, *prp->pr_sys, errno ? errno : tet_tcerrno,
			"can't change directory to", tcdir);
		return(-1L);
	}

#ifndef NOTRACE
#  ifdef TET_LITE	/* -LITE-CUT-LINE- */
	TRACE3(tet_Ttcc, 4, "about to exec %s, outfile = %s",
		argv[0], outfile ? outfile : "NULL");
#  else	/* -START-LITE-CUT- */
	TRACE6(tet_Ttcc, 4, "about to exec %s on system %s, outfile = %s, snid = %s, xrid = %s",
		argv[0], tet_i2a(*prp->pr_sys), outfile ? outfile : "NULL",
		tet_l2a(prp->pr_snid), tet_l2a(prp->pr_xrid));
#  endif /* TET_LITE */	/* -END-LITE-CUT- */
	if (tet_Ttcc >= 6) {
		for (ap = argv; *ap; ap++) {
			TRACE3(tet_Ttcc, 6, "argv[%s] = \"%s\"",
				tet_i2a(ap - argv), *ap);
		}
	}
#endif /* !NOTRACE */


	/* do the exec */
#ifdef TET_LITE	/* -LITE-CUT-LINE- */
	if ((err = tcf_exec(path, argv, outfile, -1L, TCF_EXEC_TEST, &pid)) < 0) {
		prperror(prp, *prp->pr_sys, err, "can't exec", path);
		remid = -1L;
	}
	else
		remid = (long) pid;
#else	/* -START-LITE-CUT- */
	if ((remid = tet_tctexec(*prp->pr_sys, path, argv, outfile, prp->pr_snid, prp->pr_xrid)) < 0L)
		prperror(prp, *prp->pr_sys, tet_tcerrno, "can't exec", path);
#endif /* TET_LITE */	/* -END-LITE-CUT- */

	TRACE2(tet_Ttcc, 4, "exec returns pid = %s", tet_l2a(remid));

	return(remid);
}

/*
**	sychdir() - change directory on the specified system
**		if necessary
**
**	return 0 if successful or -1 on error
*/

int sychdir(sp, dir)
struct systab *sp;
char *dir;
{
	int already_there;

	TRACE3(tet_Ttcc, 8, "sychdir(): dir = %s, sysid = %s",
		dir, tet_i2a(sp->sy_sysid));

	/* no need to do anything if we are already there */
	already_there = (sp->sy_cwd && !strcmp(dir, sp->sy_cwd)) ? 1 : 0;

	if (already_there) {
		TRACE1(tet_Ttcc, 9, "sychdir(): already there");
		return(0);
	}

	/* do the chdir */
	errno = 0;
	if (tcc_chdir(sp->sy_sysid, dir) < 0)
		return(-1);

	/* all OK so remember the cwd and return */
	if (sp->sy_cwd) {
		TRACE2(tet_Tbuf, 6, "free sy_cwd = %s", tet_i2x(sp->sy_cwd));
		free(sp->sy_cwd);
	}
	sp->sy_cwd = rstrstore(dir);
	TRACE1(tet_Ttcc, 9, "sychdir(): chdir was successful");
	return(0);
}

