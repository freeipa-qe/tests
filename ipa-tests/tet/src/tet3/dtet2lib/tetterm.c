/*
 *	SCCS: @(#)tetterm.c	1.4 (97/07/21)
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
static char sccsid[] = "@(#)tetterm.c	1.4 (97/07/21) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)tetterm.c	1.4 97/07/21 TETware release 3.7
NAME:		tetterm.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	September 1996

DESCRIPTION:
	terminate a process on WIN32

	Note that this is a dangerous function to use!
	It can leave the system in a strange state, causing subsequent
	unexpected behaviour.

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., July 1997
	Changed mapping of ERROR_INVALID_HANDLE from ECHILD to ESRCH.
	Added support the MT DLL version of the C runtime support library
	on Win32 systems.


************************************************************************/


int tet_tetterm_c_not_used;


