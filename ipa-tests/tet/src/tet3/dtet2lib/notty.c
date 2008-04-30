/*
 *      SCCS:  @(#)notty.c	1.11 (02/01/18) 
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
static char sccsid[] = "@(#)notty.c	1.11 (02/01/18) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)notty.c	1.11 02/01/18 TETware release 3.7
NAME:		notty.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	April 1992

DESCRIPTION:
	function to dissociate from control terminal and start a new process
	group

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., January 1994
	added setsid() call to support POSIX-only systems
	(mainly for the FIFO implementation)

************************************************************************/

#include <stdio.h>

#  if defined(_POSIX_SOURCE) || defined(_POSIX_C_SOURCE)
#    define HAS_SETSID
#  endif /* _POSIX_SOURCE etc. */
#  ifdef HAS_SETSID
#    include <unistd.h>
#    include <errno.h>
#  else /* HAS_SETSID */
#    include <sys/ioctl.h>
#    ifdef TIOCNOTTY
#      include <fcntl.h>
#    endif /* TIOCNOTTY */
#  endif /* HAS_SETSID */

#include "dtmac.h"
#include "dtetlib.h"

/*
**	tet_tiocnotty() - dissociate from control terminal
**		and start a new process group
*/

void tet_tiocnotty()
{


#  ifdef HAS_SETSID

	/* easy - use setsid() to start a new session */
	(void) setsid();

#  else /* HAS_SETSID */

	/* harder - must use setpgrp() and possibly TIOCNOTTY */

#    ifdef TIOCNOTTY
	int ttyfd;
#    endif

#    if defined(SVR2) || defined(SVR3) || defined(SVR4) || defined(__hpux) || defined(_AIX)
	(void) setpgrp();
#    else
	int pid = getpid();
	(void) setpgrp(pid, pid);
#    endif


#    ifdef TIOCNOTTY
	/*
	** this for BSD systems where setpgrp() does not change the
	** control terminal
	*/
	if ((ttyfd = open("/dev/tty", O_RDONLY | O_NDELAY)) >= 0) {
		(void) ioctl(ttyfd, TIOCNOTTY, 0);
		(void) close(ttyfd);
	}
#    endif /* TIOCNOTTY */

#  endif /* HAS_SETSID */


}

