/*
 *	SCCS: @(#)tetspawn.c	1.4 (98/08/28)
 *
 *	UniSoft Ltd., London, England
 *
 * (C) Copyright 1997 X/Open Company Limited
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
static char sccsid[] = "@(#)tetspawn.c	1.4 (98/08/28) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)tetspawn.c	1.4 98/08/28 TETware release 3.7
NAME:		tetspawn.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	May 1997

DESCRIPTION:
	function to spawn a new process on a WIN32 platform;
	searching the PATH and invoking an interpreter if necessary

	this function is necessary because we want to be able to cater
	for more file name extensions than _spawnvpe() understands;
	also, we can't call _spawnvpe() directly on Windows 95 because
	it doesn't understand '/' in PATH or in the file name

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., May 1998
	Use tet_basename() instead of a local static version.

************************************************************************/


int tet_tetspawn_c_not_used;


