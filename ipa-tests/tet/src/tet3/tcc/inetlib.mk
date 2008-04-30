#
#	SCCS: @(#)inetlib.mk	1.3 (96/11/04)
#
#	UniSoft Ltd., London, England
#
# (C) Copyright 1996 X/Open Company Limited
#
# All rights reserved.  No part of this source code may be reproduced,
# stored in a retrieval system, or transmitted, in any form or by any
# means, electronic, mechanical, photocopying, recording or otherwise,
# except as stated in the end-user licence agreement, without the prior
# permission of the copyright owners.
# A copy of the end-user licence agreement is contained in the file
# Licence which accompanies this distribution.
# 
# X/Open and the 'X' symbol are trademarks of X/Open Company Limited in
# the UK and other countries.
#
# ************************************************************************
# 
# SCCS:   	@(#)inetlib.mk	1.3 96/11/04 TETware release 3.7
# NAME:		makefile
# PRODUCT:	TETware
# AUTHOR:	Andrew Dingwall, UniSoft Ltd.
# DATE CREATED:	August 1996
# 
# DESCRIPTION:
#	tcc INET version aux makefile
# 
# MODIFICATIONS:
# 
# ************************************************************************

# link the generic .o files with the INET-specific .o files
OFILES = $(OFILES_GN) $(OFILES_IN)

# don't link with tcclib in fully-featured TETware
TCCLIB =

