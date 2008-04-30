/*
 *      SCCS:  @(#)fioclex.c	1.9 (97/07/21) 
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
static char sccsid[] = "@(#)fioclex.c	1.9 (97/07/21) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)fioclex.c	1.9 97/07/21 TETware release 3.7
NAME:		fioclex.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	function to set the close-on-exec bit on a file descriptor

	note that we can't do this on Windows 95 - the underlying
	WIN32 API call is not implemented for some reason.
	But since we only support TETware-Lite on Win95 it doesn't
	really matter too much.

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., May 1997
	port to Windows 95


************************************************************************/

#include <stdio.h>
#  include <fcntl.h>
#include <errno.h>
#include "dtmac.h"
#include "ltoa.h"
#include "error.h"
#include "dtetlib.h"

#ifdef NEEDsrcFile
static char srcFile[] = __FILE__;	/* file name for error reporting */
#endif

/*
**	tet_fioclex() - set the close-on-exec bit on a file descriptor
**
**	return 0 if successful or -1 on error
*/

int tet_fioclex(fd)
int fd;
{


	if (fcntl(fd, F_SETFD, 1) < 0) {
		error(errno, "can't set close-on-exec flag on fd",
			tet_i2a(fd));
		return(-1);
	}

	return(0);


}


/*
**	tet_hfioclex() - set the no-inherit bit on a HANDLE
**
**	return 0 if successful or -1 on error
*/


