/*
 *	SCCS: @(#)tetdir.h	1.3 (98/11/26)
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

/************************************************************************

SCCS:   	@(#)tetdir.h	1.3 98/11/26 TETware release 3.7
NAME:		tetdir.h
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	September 1996

DESCRIPTION:
	a header file used to switch between the directory access
	mechanisms used on different platforms

	Note: FreeBSD 3.0 (at least) requires <sys/types.h> to be included
	before this file.

MODIFICATIONS:

************************************************************************/

/*
** select which system header files to include (if any), depending
** on which #define has been specified in dtmac.h
*/

#ifdef NDIR
#  include <sys/ndir.h>
#  define dirent direct
#else
#  ifdef DIRENT
#    include <dirent.h>
#  else
#    ifdef SYSDIR
#      include <sys/dir.h>
#      define dirent direct
#    else
#      ifdef TETDIR
         /* we will use the compatibility routines in dtet2lib/tetdir.c */
#      else
#        error no directory access macro specified in dtmac.h
#      endif /* TETDIR */
#    endif /* SYSDIR */
#  endif /* DIRENT */
#endif /* NDIR */



