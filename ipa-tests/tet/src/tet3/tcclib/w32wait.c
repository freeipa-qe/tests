/*
 *	SCCS: @(#)w32wait.c	1.3 (97/07/21)
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
static char sccsid[] = "@(#)w32wait.c	1.3 (97/07/21) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)w32wait.c	1.3 97/07/21 TETware release 3.7
NAME:		w32wait.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	October 1996

DESCRIPTION:
	tcc action function - wait for a process to terminate

	for use on WIN32 platforms

	this function moved from tccd/exec.c to here

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., July 1997
	added support the MT DLL version of the C runtime support library
	on Win32 systems


************************************************************************/


int tet_w32wait_c_not_used;


