/*
 *      SCCS:  @(#)eaccess.c	1.12 (99/04/21) 
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
static char sccsid[] = "@(#)eaccess.c	1.12 (99/04/21) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)eaccess.c	1.12 99/04/21 TETware release 3.7
NAME:		eaccess.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	June 1992

DESCRIPTION:
	function to check access permissions wrt effective user and group IDs

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., January 1994
	use S_ISDIR instead of S_IFMT for strict posix conformance

	Geoff Clare, UniSoft Ltd., August 1996
	Missing <unistd.h>.

	Andrew Dingwall, UniSoft Ltd., March 1999
	On UNIX systems, check group permissions w.r.t. supplementary
	group IDs as well as against the egid.

************************************************************************/

#include <stdio.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#  include <limits.h>
#  include <unistd.h>
#include "dtmac.h"
#include "error.h"
#include "ltoa.h"
#include "dtetlib.h"


#ifdef NEEDsrcFile
static char srcFile[] = __FILE__;	/* file name for error reporting */
#endif


/* static function declarations */
static int check_grouplist PROTOLIST((struct STAT_ST *, int));


/*
**	tet_eaccess() - like access() but checks permissions wrt
**		effective user and group IDs
**
**	Note: this routine assumes that access and file modes are
**	encoded in the traditional way; ie: 4 = read, 2 = write, 1 = exec
**	user perms = 0700, group perms = 070, other perms = 07.
**
**	Since this routine provides support for the tccd OP_ACCESS
**	request (among other things) and thus needs to be able to
**	receive a mode argument from another system, it will be necessary
**	to implement a machine-independent mode transfer mechanism if
**	the above assumption is incorrect for a particular system.
*/

int tet_eaccess(path, mode)
char *path;
register int mode;
{
	struct STAT_ST stbuf;


	uid_t euid;
	int rc, rc2;

	/*
	** first check for things like non-existent file,
	** read-only file system etc.
	*/
	if (ACCESS(path, mode) < 0) {
		if (errno != EACCES)
			return(-1);
	}
	else
		if ((mode &= 07) == 0)
			return(0);

	/*
	** here if access() succeeded, or failed because of wrong permissions;
	** first get the file permissions
	*/
	if (STAT(path, &stbuf) < 0)
		return(-1);

	/*
	** check the permissions wrt the euid, the egid and the
	** supplementary groups list;
	** treating root specially (like the kernel does)
	*/
	rc = 0;
	if ((euid = geteuid()) == 0) {
		if (!S_ISDIR(stbuf.st_mode) &&
			(stbuf.st_mode & 0111) == 0 && (mode & 01))
				rc = -1;
	}
	else if (stbuf.st_uid == euid) {
		if (((stbuf.st_mode >> 6) & mode) != mode)
			rc = -1;
	}
	else if (stbuf.st_gid == getegid()) {
		if (((stbuf.st_mode >> 3) & mode) != mode)
			rc = -1;
	}
	else {
		rc2 = check_grouplist(&stbuf, mode);
		switch (rc2) {
		case 2:
			break;
		case 1:
			rc = -1;
			break;
		case 0:
			if ((stbuf.st_mode & mode) != mode)
				rc = -1;
			break;
		case -1:
			return(-1);
		default:
			/* "can't happen" */
			fatal(0, "check_grouplist() returned unexpected value",
				tet_i2a(rc2));
			/* NOTREACHED */
			return(-1);
		}
	}

	if (rc < 0)
		errno = EACCES;
	return(rc);


}



/*
**	check_grouplist() - check the requested access mode against
**		the process's supplementary grouplist
**
**	return	 2 if a supplementary group matched and group access is allowed
**		 1 if a supplementary group matched but group access is
**		   not allowed
**		 0 if no supplementary groups matched
**		-1 on error (with errno set)
*/

static int check_grouplist(stp, mode)
struct STAT_ST *stp;
int mode;
{
	int errsave, ngids, ngmax;
	gid_t *gidp;
	static gid_t *gids = (gid_t *) 0;
	static int lgids = 0;

	/*
	** allocate a buffer to hold the supplementary group list;
	** we only evaluate NGROUPS_MAX once because on some systems it
	** can be a call to sysconf()
	*/
	ngmax = (int) NGROUPS_MAX;
	if (BUFCHK((char **) &gids, &lgids, ngmax * (int) sizeof *gidp) < 0) {
		errno = ENOMEM;
		return(-1);
	}

	/*
	** get the supplementary group list from the kernel;
	** it probably won't change from one invocation of tet_eaccess() to
	** the next, but we get it on each call just to be on the safe side
	**/
	if ((ngids = getgroups(ngmax, gids)) < 0) {
		errsave = errno;
		error(errno, "can't get supplementary group list", (char *) 0);
		errno = errsave;
		return(-1);
	}

	/*
	** check the file's group id against each supplementary group;
	** if the groups match, see if the requested access permission(s)
	** will be granted
	*/
	for (gidp = gids; gidp < gids + ngids; gidp++)
		if (stp->st_gid == *gidp)
			return(((stp->st_mode >> 3) & mode) == mode ? 2 : 1);

	return(0);
}


