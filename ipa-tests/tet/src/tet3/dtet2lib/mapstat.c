/*
 *	SCCS: @(#)mapstat.c	1.8 (98/08/28)
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
static char sccsid[] = "@(#)mapstat.c	1.8 (98/08/28) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)mapstat.c	1.8 (98/08/28) TETware release 3.7
NAME:		mapstat.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	August 1996

DESCRIPTION:
	function to convert from a system-specific wait() status
	to a (traditionally-encoded) value which can be transmitted to
	a remote system

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., June 1997
	removed register storage class from the function's parameter -
	portability fix for systems where a W* macro takes the address
	of its argument

	Andrew Dingwall, UniSoft Ltd., March 1998
	Corrected return value for non-zero exit status on Win32 systems
	where low 8 bits are zero.

************************************************************************/

#include <stdio.h>
#  include <sys/types.h>
#  include <sys/wait.h>
#include "dtmac.h"
#include "dtetlib.h"

/*
**	tet_mapstatus() - attempt to convert an exit status to the
**		traditional encoding for transmission to a remote system
**
**	we use the traditional encodings because there is no way for
**	the process at the other end to re-consititute the status in a
**	form that is suitable for use with the W* macros on that system
*/

int tet_mapstatus(status)
int status;
{

#  if defined(WIFEXITED) && defined(WEXITSTATUS)

	if (WIFEXITED(status))
		return((WEXITSTATUS(status) & 0377) << 8);
	else if (WIFSIGNALED(status))
		return(
			(WTERMSIG(status) & 0177)
#    ifdef WCOREDUMP	/* AIX (at least) does not have WCOREDUMP */
			| (WCOREDUMP(status) ? 0200 : 0)
#    endif
		);
	else if (WIFSTOPPED(status))
		return(((WSTOPSIG(status) & 0377) << 8) | 0177);
	else

#  endif /* WIFEXITED && WEXITSTATUS */

		return(status & 017777);


}

