/*
 *	SCCS: @(#)wsaerr.c	1.4 (97/07/21)
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
static char sccsid[] = "@(#)wsaerr.c	1.4 (97/07/21) TET3 release 3.7";
#endif

/************************************************************************

SCCS:   	@(#)wsaerr.c	1.4 97/07/21 TETware release 3.7
NAME:		wsaerr.c
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	September 1996

DESCRIPTION:
	function to return a printable representation of a
	Winsock error code

	note that although this function is only relevant to the INET
	network transport on WIN32 platforms, it is included in
	dtet2lib (rather than inetlib) because it is referenced by
	error handler code that is itself not specific to any particular
	network transport

MODIFICATIONS:

************************************************************************/


int tet_wsaerr_c_not_used;


