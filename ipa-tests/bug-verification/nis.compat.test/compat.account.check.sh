#!/bin/sh

HOST=$1
if [ -z $HOST ]
then
	echo "please run as $0 <hostname>"
	HOST=`hostname -f`
fi

LDAPSEARCH=/usr/lib*/mozldap/ldapsearch
TMPDIR=/tmp/test

DM="cn=directory manager"
PW="redhat123"
SUFFIX="dc=rhqa,dc=net"
USER_COMPAT_DN="cn=users,cn=compat,$SUFFIX"
GRP_COMPAT_DN="cn=groups,cn=compat,$SUFFIX"
USER_REGULAR_DN="cn=users,cn=accounts,$SUFFIX"
GRP_REGULAR_DN="cn=groups,cn=accounts,$SUFFIX"

USER_COMPAT_FILE=$TMPDIR/compatuser.$RANDOM.txt
GRP_COMPAT_FILE=$TMPDIR/compatgrp.$RANDOM.txt
USER_REGULAR_FILE=$TMPDIR/regularuser.$RANDOM.txt
GRP_REGULAR_FILE=$TMPDIR/regulargrp.$RANDOM.txt


echo "
compat user & group samples are below
	[uid=d-91-9,cn=users,cn=compat,dc=rhqa,dc=net]
	[cn=grp-81,cn=groups,cn=compat,dc=rhqa,dc=net]
regular user & group are below
	[uid=d-91-9,cn=users,cn=accounts,dc=rhqa,dc=net]
	[cn=grp-81,cn=groups,cn=accounts,dc=rhqa,dc=net]
"

find_it()
{
	dn=$1
	file=$2
	$LDAPSEARCH -h $HOST -D "$DM" -w $PW -s sub -b $dn "" "dn" | grep "dn" |cut -d":" -f2 | cut -d"," -f1 | cut -d"=" -f2 | grep -v "ipausers"| grep -v "admin" | grep -v "editors" | grep -v "groups" | sort > $file
}

get_compatgroup_member ()
{
	gid=$1
	file=$2
	$LDAPSEARCH -h $HOST -D "$DM" -w $PW -s sub -b "cn=$gid,$GRP_COMPAT_DN" "" "memberUid" | grep "memberUid" | cut -d" " -f2 | sort > $file
}

get_regulargroup_member ()
{
        gid=$1
        uidfile=$2
	echo "	[gid=$gid], user save to [$uidfile]"
        gidfile=$TMPDIR/group.$gid.grp-members.$RANDOM.txt
        file=$TMPDIR/group.$gid.all-members.$RANDOM.txt
	touch $gidfile 
	touch $file
        $LDAPSEARCH -h $HOST -D "$DM" -w $PW -s sub -b "cn=$gid,$GRP_REGULAR_DN" "" "member" | grep "member" | cut -d":" -f2 |cut -d"," -f1| sort > $file
        # start to separate the users and groups
        grep "uid" $file | cut -d"=" -f2 >> $uidfile
        grep "cn" $file | cut -d"=" -f2 > $gidfile
        for grp in `cat $gidfile`
        do
                echo "	trace down sub group [$grp]"
                get_regulargroup_member $grp $uidfile 
        done
}

create_storage()
{
	for f in $USER_COMPAT_FILE $GRP_COMPAT_FILE $USER_REGULAR_FILE $GRP_REGULAR_FILE 
	do
		if ! touch $f
		then
			echo "can not create in [$TMPDIR] for storage purpose, please check it, for now, exit test"
			exit
		fi
	done
	echo "================================================================"
	echo "[compat  user file] : [$USER_COMPAT_FILE]"
	echo "[regular user file] : [$USER_REGULAR_FILE]"
	echo "[compat  group file]: [$GRP_COMPAT_FILE]"
	echo "[regular group file]: [$GRP_REGULAR_FILE]"
	echo "================================================================"
}

delete_storage()
{
	for f in $USER_COMPAT_FILE $GRP_COMPAT_FILE $USER_REGULAR_FILE $GRP_REGULAR_FILE
	do
		rm $f
		echo "[$f] removed"
	done
}

create_storage

find_it $USER_COMPAT_DN $USER_COMPAT_FILE
find_it $GRP_COMPAT_DN  $GRP_COMPAT_FILE
find_it $USER_REGULAR_DN $USER_REGULAR_FILE
find_it $GRP_REGULAR_DN $GRP_REGULAR_FILE

if diff $USER_COMPAT_FILE $USER_REGULAR_FILE
then
	echo ""
	echo "==================================================="
	echo "compat user matchs regular user, test PASSED "
	echo "==================================================="
else
	echo "==================================================="
	echo "users doesn't match, test FAILED"
	echo "==================================================="
	exit
fi


if diff $GRP_COMPAT_FILE $GRP_REGULAR_FILE
then
	echo ""
	echo "================================================================"
	echo "compat group matchs regular groups, test PASSED the frirst step "
	echo "--------------------------------------------------------------"
	echo "now doing member and memberUid match test"
	echo "================================================================"
	echo ""
	for groupid in `cat $GRP_REGULAR_FILE`
	do
		echo "================================================================"
		echo "| compare members in group [$groupid] "
		echo "================================================================"
		compat_group_members=$TMPDIR/compat.group.members.$groupid.$RANDOM.txt
		regular_group_members=$TMPDIR/regular.group.members.$groupid.$RANDOM.txt
		touch $compat_group_members 
		touch $regular_group_members
		get_compatgroup_member $groupid $compat_group_members
		get_regulargroup_member $groupid $regular_group_members
		if diff $compat_group_members $regular_group_members
		then
			echo "	matched, PASS"
		else
			echo "	DOES NOT match, FAILED"
		fi	
		echo "	[regular] in file [$regular_group_members]"
		echo "	[compat]  in file [$compat_group_members]"
		echo "----------- done for [$groupid] at [`date`] -------------------"
		echo ""
	done
else
	echo "group name doesn't match, test FAILED"
fi

#delete_storage
