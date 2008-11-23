#!/bin/bash
set -x

LDCLT=/usr/bin/ldclt
HOSTNAME=tigger.dsqa.sjc2.redhat.com
PORT=389
BIND_DN="cn=directory manager"
BIND_PW=Secret123
BASE_SUFFIX="dc=dsqa,dc=sjc2,dc=redhat,dc=com"
USER_SUFFIX="cn=users,cn=accounts,$BASE_SUFFIX"
USER_COMPAT_SUFFIX="cn=users,cn=compat,cn=accounts,$BASE_SUFFIX"
GROUP_SUFFIX="cn=groups,cn=accounts,$BASE_SUFFIX"
GROUP_COMPAT_SUFFIX="cn=groups,cn=compat,cn=accounts,$BASE_SUFFIX"
MIN_RANGE=1
MAX_RANGE=1000

# set what operations to do
ADD_OPS=1
MOD_OPS=1
SEARCH_OPS=1
DELETE_OPS=1


#######################################################################
# ACTUAL RUN TEST

if [ "$ADD_OPS" = "1" ]
then
	# add users
	$LDCLT -h $HOSTNAME -p $PORT -D "$BIND_DN" -w "$BIND_PW" \
        -b "$USER_SUFFIX" -n 1 -I 68 \
        -e object=users.txt,rdn="uid:[A=INCRN($MIN_RANGE;$MAX_RANGE;5)]" \
        -v -e add,commoncounter &

	# add groups - also adds one user as member
	$LDCLT -h $HOSTNAME -n 1 -p $PORT -D "$BIND_DN" -w "$BIND_PW" \
	        -b "$GROUP_SUFFIX" -I 68 \
	        -e object=groups.txt,rdn="cn:[A=INCRN($MIN_RANGE;$MAX_RANGE;5)]" \
	        -v -e add,commoncounter &
fi

#######################################################################

if [ "$MOD_OPS" = "1" ]
then

	# replace password attr for users
	$LDCLT  -D "$BIND_DN"   -w "$BIND_PW" -h alice.dsdev.sjc.redhat.com   -p $PORT     \
		-e attreplace=userpassword:"a_random_sn_XXXX"          \
		-e incr     -b "$USER_SUFFIX"     -f "uid=XXXXX"     \
		-v -n 1 -r $MIN_RANGE -R $MAX_RANGE -I 32  &

	# replace group membership
	$LDCLT  -D "$BIND_DN"   -w "$BIND_PW" -h alice.dsdev.sjc.redhat.com   -p $PORT     \
		-e attreplace=member:"uid=XXXXX,$USER_SUFFIX"          \
		-e incr     -b "$GROUP_SUFFIX"     -f "cn=XXXXX"     \
		-v -n 1 -r $MIN_RANGE -R $MAX_RANGE -I 32  &

fi
#######################################################################

if [ "$SEARCH_OPS" = "1" ]
then
	# searches - individual users for memberof
	$LDCLT  -D "$BIND_DN"   -w "$BIND_PW" -h $HOSTNAME   -p $PORT     \
		-e esearch,incr     -b "$USER_SUFFIX"     -f "uid=XXXXX"     \
		-e attrlist=cn:sn:uid:memberof \
		-v -n 2 -r $MIN_RANGE -R $MAX_RANGE -I 32  &

	# searches - compat suffix for users and groups
	$LDCLT  -D "$BIND_DN"   -w "$BIND_PW" -h $HOSTNAME   -p $PORT     \
		-e esearch,incr     -b "$GROUP_COMPAT_SUFFIX"     -f "cn=XXXXX"     \
		-e attrlist=cn:sn:memberuid \
		-v -n 2 -r $MIN_RANGE -R $MAX_RANGE -I 32  &

fi

#######################################################################
if [ "$DELETE_OPS" = "1" ]
then

	# delete users
	$LDCLT -h margo.dsqa.sjc2.redhat.com -p $PORT -D "$BIND_DN" -w "$BIND_PW" \
		-e incr     -e delete -b "$USER_SUFFIX"     -f "uid=XXXXX"     \
		-v -n 1 -r $MIN_RANGE -R $MAX_RANGE -I 32  &
	

	# delete groups
	$LDCLT -h margo.dsqa.sjc2.redhat.com -p $PORT -D "$BIND_DN" -w "$BIND_PW" \
		-e incr     -e delete -b "$GROUP_SUFFIX"     -f "cn=XXXXX"     \
		-v -n 1 -r $MIN_RANGE -R $MAX_RANGE -I 32  &

fi

#######################################################################
