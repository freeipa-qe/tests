/*
 *	SCCS: @(#)sigsafe.h	1.5 (98/08/28)
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

SCCS:   	@(#)sigsafe.h	1.5 98/08/28 TETware release 3.7
NAME:		sigsafe.h
PRODUCT:	TETware
AUTHOR:		Andrew Dingwall, UniSoft Ltd.
DATE CREATED:	September 1996

DESCRIPTION:
	a header file for use with the sigsafe functions

MODIFICATIONS:
	Andrew Dingwall, UniSoft Ltd., July 1997
	removed the sigsafe code on WIN32 platforms

	Andrew Dingwall, UniSoft Ltd., July 1998
	Added support for shared API libraries.
 
************************************************************************/

/*
** variable definition to use for the sigsafe functions
** and how to call the functions themselves
*/
#  define TET_SIGSAFE_DEF	sigset_t oldset;
#  define TET_SIGSAFE_START	(void) tet_sigsafe_start(&oldset)
#  define TET_SIGSAFE_END	(void) tet_sigsafe_end(&oldset)

/* set of all blockable signals (to be blocked during critical code) */
   TET_EXPORT_DATA(sigset_t, tet_blockable_sigs);

/* extern function declarations */
TET_IMPORT_FUNC(void, tet_init_blockable_sigs, PROTOLIST((void)));

   extern int tet_sigsafe_end PROTOLIST((sigset_t *));
   extern int tet_sigsafe_start PROTOLIST((sigset_t *));

