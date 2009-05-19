#!/bin/ksh

######################################################################
# The following ipa cli commands needs to be tested:
#  hostgroup-add             Add a new hostgroup.
#  hostgroup-add-member      Add a member to a hostgroup.
#  hostgroup-del             Delete an existing hostgroup.
#  hostgroup-find            Search the groups.
#  hostgroup-mod             Edit an existing hostgroup.
#  hostgroup-remove-member   Remove a member from a hostgroup.
#  hostgroup-show            Examine an existing hostgroup.
######################################################################

if [ "$DSTET_DEBUG" = "y" ]; then
	set -x
fi

######################################################################
#  Test Case List
#####################################################################
iclist="ic0 ic1 ic2 ic3 ic4 ic5 ic6 ic7 ic8 ic9 ic10 ic11 ic12 ic13 ic14 ic15 ic16 ic17"
ic0="startup"
ic1="hostgrpcli_001" 
ic2="hostgrpcli_002"
ic3="hostgrpcli_003"
ic4="hostgrpcli_004"
ic5="hostgrpcli_005" 
ic6="hostgrpcli_006" 
ic7="hostgrpcli_007"
ic8="hostgrpcli_008"
ic9="hostgrpcli_009"
ic10="hostgrpcli_010"
ic11="hostgrpcli_011"
ic12="hostgrpcli_012"
ic13="hostgrpcli_013"
ic14="hostgrpcli_014"
ic15="hostgrpcli_015"
ic16="cleanup"
ic17="bug499731"
########################################################################
#  sub routines
########################################################################
os_nslookup()
{
h=$1
case $ARCH in
	"Linux "*)
		rval=`nslookup -sil $h`
		if [ `expr "$rval" : "server can't find"` -gt 0 ]; then
			tmpdn=`domainname -f`
			echo "Name: $tmpdn"
			tmpaddr=`/sbin/ifconfig -a | egrep inet | egrep -v 127.0.0.1 | egrep -v inet6 | awk '{print $2}' | awk -F: '{print $2}'`
			echo "Addr: $tmpaddr"
		else
			nslookup -sil $h
		fi
		;;
	*)
		nslookup $h
		;;
esac
}

os_getdomainname()
{
   mydn=`hostname | os_nslookup 2> /dev/null | grep 'Name:' | cut -d"." -f2-`
   if [ "$mydn" = "" ]; then
     mydn=`hostname -f |  cut -d"." -f2-`
   fi
   echo "$mydn"
}

mykinit()
{
   	userid=$1
  	userpwd=$2
	rc=0
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        # Kinit everywhere
        for s in $SERVERS; do
                if [ "$s" != "" ]; then
                        message "kiniting as $userid, password $userpwd on $s"
                        KinitAs $s $userid $userpwd
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
				rc=1
                        fi
                else
                        message "skipping $s"
                fi
        done
        for s in $CLIENTS; do
                if [ "$s" != "" ]; then
                        message "kiniting as $userid, password $userpwd on $s"
                        KinitAs $s $userid $userpwd
                        if [ $? -ne 0 ]; then
                                message "ERROR - kinit on $s failed"
                      		rc=1
                        fi
                fi
        done

	return $rc
}

#######################################################################
#  Variables
######################################################################
realm=`os_getdomainname`
REALM=`echo $realm | tr "[a-z]" "[A-Z]"`
BASEDN=`echo $realm | sed 's/^/dc=/' | sed 's/\./,dc=/g'`
DOMAIN="idm.lab.bos.redhat.com"

host1="nightcrawler."$DOMAIN
host2="ivanova."$DOMAIN
host3="samwise."$DOMAIN
host4="shadowfall."$DOMAIN
host5="qe-blade-01."$DOMAIN

group1="hostgrp1"
group2="host group 2"
group3="host-group_3"
group4="parent host group"
group5="child host group"

set -A ugrplist usrgrp1 usrgrp2 usrgrp3 usrgrp4 usrgrp5
set -A grouplist "$group1" "$group2" "$group3" "$group4" "$group5"
set -A hostlist $host1 $host2 $host3 $host4 $host5

########################################################################
#  The following tests will be executed as the default super user - admin
########################################################################
startup()
{
	myresult=PASS
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	# Kinit everywhere
	message "START $tet_thistest"

	mykinit $DS_USER $DM_ADMIN_PASS
	if [ $? -ne 0 ]; then
		myresult=FAIL
	fi

	# let's add some hosts that we can test host group members with
        i=0
        s="M1" 
        eval_vars $s
	while [ $i -lt ${#hostlist[@]} ] ; do
		echo "adding host  \"${hostlist[$i]}\""
		ssh root@$FULLHOSTNAME "ipa host-add \"${hostlist[$i]}\""
                if [ $? -ne 0 ] ; then
                	message "ERROR - ipa host-add failed on $FULLHOSTNAME"
                	myresult=FAIL
		else
			message "ipa host-add successful for  \"${hostlist[$i]}\" on $FULLHOSTNAME"
                fi
                ((i=$i+1))
	done

	result $myresult
	message "END $tet_thistest"

	# let's add some user groups that we can test user group members with
        i=0
        s="M1"
        eval_vars $s
	description="Test User Group"
        while [ $i -lt ${#ugrplist[@]} ] ; do
                echo "adding user group \"${ugrplist[$i]}\""
                ssh root@$FULLHOSTNAME "ipa group-add --description=\"$description\" \"${ugrplist[$i]}\""
                if [ $? -ne 0 ] ; then
                        message "ERROR - ipa group-add failed on $FULLHOSTNAME"
                        myresult=FAIL
                else
                        message "ipa group-add successful for  \"${ugrplist[$i]}\" on $FULLHOSTNAME"
                fi
                ((i=$i+1))
        done

	result $myresult
	message "END $tet_thistest"
}

hostgrpcli_001()
{
	myresult=PASS
        message "START $tet_thistest: Add Host Groups"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s
			i=0
			while [ $i -lt ${#grouplist[@]} ] ; do
			  upper=`echo  ${grouplist[$i]} |  tr "[a-z]" "[A-Z]"` 
			  description="Testing Host Group"
			  # test for ipa hostgroup-add
			  echo "adding group  \"${grouplist[$i]}\""
			  ssh root@$FULLHOSTNAME "ipa hostgroup-add --description=\"$description\" \"${grouplist[$i]}\""
			  if [ $? -ne 0 ]
			  then
				message "ERROR - ipa hostgroup-add failed on $FULLHOSTNAME"
				myresult=FAIL
			  fi
			  # Verifying lower case
			  ssh root@$FULLHOSTNAME "ipa hostgroup-find \"${grouplist[$i]}\" | grep \"${grouplist[$i]}\""
			  if [ $? -ne 0 ]
			  then
				message "ERROR - ipa hostgroup-find \"${grouplist[$i]}\" failed on $FULLHOSTNAME"
				myresult=FAIL
			  else
				message "ipa hostgroup-find successful for \"${grouplist[$i]}\" on $FULLHOSTNAME"
			  fi
			  # Verifying upper case
                          ssh root@$FULLHOSTNAME "ipa hostgroup-find \"$upper\" | grep \"${grouplist[$i]}\""
                          if [ $? -ne 0 ]
                          then
                                message "ERROR - ipa hostgroup-find \"$upper\" failed on $FULLHOSTNAME"
                                myresult=FAIL
                          else
                                message "ipa hostgroup-find successful for \"$upper\" on $FULLHOSTNAME"

                          fi
			  ((i=$i+1))
		  	done
		fi
	done

	result $myresult
	message "END $tet_thistest"
}

hostgrpcli_002()
{
	myresult=PASS
        message "START $tet_thistest: Modify Host Description"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s
			i=0
                        while [ $i -lt ${#grouplist[@]} ] ; do
				description="This is a new description for ${grouplist[$i]}"
                        	ssh root@$FULLHOSTNAME "ipa hostgroup-mod --description=\"$description\" \"${grouplist[$i]}\""
                        	if [ $? -ne 0 ] ; then
                                  message "ERROR - ipa hostgroup-mod failed on $FULLHOSTNAME"
                                  myresult=FAIL
                        	fi

                        	# Verify description
                        	value=`ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\" | grep description:"`
                        	value=`echo $value | awk -F: '{print $2}'`
                        	#trim white space
                        	value=`echo $value`
                        	if [ $value -ne $description ] ; then
                                 message "ERROR - \"${grouplist[$i]}\" description not correct on $FULLHOSTNAME expected: $description  got: $value"
                                 myresult=FAIL
                        	else
                                  message "Host \"${grouplist[$i]}\" description is as expected: $value"
                        	fi
				((i=$i+1))
			done
                fi
        done

        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_003()
{
	myresult=PASS
	tmpfile=$TET_TMP_DIR/members.txt
	message "START $tet_thistest: Add Hosts to Host Groups"
	if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	for s in $SERVERS; do
		if [ "$s" == "M1" ]; then
			eval_vars $s

			#### Add all hosts to all groups ####
			i=0
			while [ $i -lt ${#grouplist[@]} ] ; do
				h=0
				while [ $h -lt ${#hostlist[@]} ] ; do
				  # add host to host group
				  ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hosts=${hostlist[$h]} \"${grouplist[$i]}\""
				  if [ $? -ne 0 ] ; then
				     message "ERROR - ipa hostgroup-add-member host \"${hostlist[$h]}\" to \"${grouplist[$i]}\" failed on $FULLHOSTNAME"
				     myresult=FAIL
				  fi
				  ((h=$h+1))
				done
			   ((i=$i+1))
			done

			##### Verify host memberships #####
			i=0
			while [ $i -lt ${#grouplist[@]} ] ; do
                           # verify membership
                           ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
			   h=0
			   while [ $h -lt ${#hostlist[@]} ] ; do
				cat $tmpfile | grep "${hostlist[$h]}"
				if [ $? -ne 0 ] ; then
				  message "ERROR - \"${hostlist[$h]}\" is not a member of \"${grouplist[$i]}\" and should be - failed on $FULLHOSTNAME"
				  myresult=FAIL
			 	else
				   message "\"${hostlist[$h]}\" is a member of \"${grouplist[$i]}\" - verified on $FULLHOSTNAME"
				fi
				((h=$h+1))
			   done
			   ((i=$i+1))
			done
		fi
	done
	
	rm -rf $tmpfile
	result $myresult
	message "END $tet_thistest"
}

hostgrpcli_004()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Add User Groups to Host Groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s

                        #### Add all user groups to all host groups ####
                        i=0
                        while [ $i -lt ${#grouplist[@]} ] ; do
                                h=0
                                while [ $h -lt ${#ugrplist[@]} ] ; do
                                  ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --groups=${ugrplist[$h]} \"${grouplist[$i]}\""
                                  if [ $? -ne 0 ] ; then
                                     message "ERROR - ipa hostgroup-add-member user group \"${ugrplist[$h]}\" to \"${grouplist[$i]}\" failed on $FULLHOSTNAME"
                                     myresult=FAIL
                                  fi
                                  ((h=$h+1))
                                done
                           ((i=$i+1))
                        done

                        ##### Verify user group memberships #####
                        i=0
                        while [ $i -lt ${#ugrplist[@]} ] ; do
                           # verify membership
                           ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
                           h=0
                           while [ $h -lt ${#ugrplist[@]} ] ; do
                                cat $tmpfile | grep "${ugrplist[$h]}"
                                if [ $? -ne 0 ] ; then
                                  message "ERROR - \"${ugrplist[$h]}\" is not a member of \"${grouplist[$i]}\" and should be - failed on $FULLHOSTNAME"
                                  myresult=FAIL
                                else
                                   message "\"${ugrplist[$h]}\" is a member of \"${grouplist[$i]}\" - verified on $FULLHOSTNAME"
                                fi
                                ((h=$h+1))
                           done
                           ((i=$i+1))
                        done
                fi
        done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_005()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Remove Hosts from Host Groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s

                        #### Remove all hosts from all groups ####
                        i=0
                        while [ $i -lt ${#grouplist[@]} ] ; do
                                h=0
                                while [ $h -lt ${#hostlist[@]} ] ; do
                                  ssh root@$FULLHOSTNAME "ipa hostgroup-remove-member --hosts=${hostlist[$h]} \"${grouplist[$i]}\""
                                  if [ $? -ne 0 ] ; then
                                     message "ERROR - ipa hostgroup-remove-member host \"${hostlist[$h]}\" to \"${grouplist[$i]}\" failed on $FULLHOSTNAME"
                                     myresult=FAIL
                                  fi
                                  ((h=$h+1))
                                done
                           ((i=$i+1))
                        done

                        ##### Verify host memberships #####
                        i=0
                        while [ $i -lt ${#grouplist[@]} ] ; do
                           # verify membership
                           ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
                           h=0
                           while [ $h -lt ${#hostlist[@]} ] ; do
                                cat $tmpfile | grep "${hostlist[$h]}"
                                if [ $? -eq 0 ] ; then
                                  message "ERROR - \"${hostlist[$h]}\" is still a member of \"${grouplist[$i]}\" and should not be - failed on $FULLHOSTNAME"
                                  myresult=FAIL
                                else
                                   message "\"${hostlist[$h]}\" is no longer a member of \"${grouplist[$i]}\" - verified on $FULLHOSTNAME"
                                fi
                                ((h=$h+1))
                           done
                           ((i=$i+1))
                        done
                fi
        done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_006()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Remove User Groups from Host Groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s

                        #### Remove all user groups to all host groups ####
                        i=0
                        while [ $i -lt ${#grouplist[@]} ] ; do
                                h=0
                                while [ $h -lt ${#ugrplist[@]} ] ; do
                                  ssh root@$FULLHOSTNAME "ipa hostgroup-remove-member --groups=\"${ugrplist[$h]}\" \"${grouplist[$i]}\""
                                  if [ $? -ne 0 ] ; then
                                     message "ERROR - ipa hostgroup-remove-member user group \"${ugrplist[$h]}\" from \"${grouplist[$i]}\" failed on $FULLHOSTNAME"
                                     myresult=FAIL
                                  fi
                                  ((h=$h+1))
                                done
                           ((i=$i+1))
                        done

                        ##### Verify user group memberships #####
                        i=0
                        while [ $i -lt ${#ugrplist[@]} ] ; do
                           # verify membership
                           ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
                           h=0
                           while [ $h -lt ${#ugrplist[@]} ] ; do
                                cat $tmpfile | grep "${ugrplist[$h]}"
                                if [ $? -eq 0 ] ; then
                                  message "ERROR - \"${ugrplist[$h]}\" is still a member of \"${grouplist[$i]}\" and should not be - failed on $FULLHOSTNAME"
                                  myresult=FAIL
                                else
                                   message "\"${ugrplist[$h]}\" is no longer a member of \"${grouplist[$i]}\" - verified on $FULLHOSTNAME"
                                fi
                                ((h=$h+1))
                           done
                           ((i=$i+1))
                        done
                fi
        done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_007()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Nested Host Groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                        eval_vars $s

			#### Add Nested Host groups ####
                        ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hostgroups=\"$group5\" \"$group4\""
                        if [ $? -ne 0 ] ; then
                        	message "ERROR - ipa hostgroup-add-member \"$group5\" to \"$group4\" failed on $FULLHOSTNAME"
                        	myresult=FAIL
                        fi
			
                        ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hostgroups="\"$group1\",\"$group2\",\"$group3\"" \"$group5\""
                        if [ $? -ne 0 ] ; then
                                message "ERROR - ipa hostgroup-add-member failed on $FULLHOSTNAME. rc: $?"
                                myresult=FAIL
                        fi
	
			##### Verify Group Memberships ####
			ssh root@$FULLHOSTNAME "ipa hostgroup-show \"$group4\"" > $tmpfile
			cat $tmpfile | grep "$group5"
			if [ $? -ne 0 ] ; then
				message "ERROR - \"$group5\" should be a member of \"$group4\" but is not - failed on $FULLHOSTNAME"
			else
				message "\"$group5\" is a member of \"$group4\""
			fi

                        ssh root@$FULLHOSTNAME "ipa hostgroup-show \"$group5\"" > $tmpfile
                        cat $tmpfile | grep "$group1"
                        if [ $? -ne 0 ] ; then
                                message "ERROR - \"$group1\" should be a member of \"$group4\" but is not - failed on $FULLHOSTNAME"
                        else
                                message "\"$group1\" is a member of \"$group4\""
                        fi

                        cat $tmpfile | grep "$group2"
                        if [ $? -ne 0 ] ; then
                                message "ERROR - \"$group2\" should be a member of \"$group4\" but is not - failed on $FULLHOSTNAME"
                        else
                                message "\"$group2\" is a member of \"$group4\""
                        fi

                        cat $tmpfile | grep "$group3"
                        if [ $? -ne 0 ] ; then
                                message "ERROR - \"$group3\" should be a member of \"$group4\" but is not - failed on $FULLHOSTNAME"
                        else
                                message "\"$group3\" is a member of \"$group4\""
                        fi
		fi
	done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_008()
{

        myresult=PASS
	tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Remove Nested Group Memberships"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
             eval_vars $s

            #### Remove all user groups to all host groups ####
            ssh root@$FULLHOSTNAME "ipa hostgroup-remove-member --hostgroups=\"$group5\" \"$group4\""
            if [ $? -ne 0 ] ; then
            	message "ERROR - ipa hostgroup-remove-member \"$group5\" to \"$group4\" failed on $FULLHOSTNAME"
            	myresult=FAIL
            fi

            ssh root@$FULLHOSTNAME "ipa hostgroup-remove-member --hostgroups="\"$group1\",\"$group2\",\"$group3\"" \"$group5\""
            if [ $? -ne 0 ] ; then
            	message "ERROR - ipa hostgroup-remove-member failed on $FULLHOSTNAME. rc: $?"
            	myresult=FAIL
            fi

	    ##### Verify hostgroups are removed ####
            ssh root@$FULLHOSTNAME "ipa hostgroup-show \"$group4\"" > $tmpfile
            cat $tmpfile | grep "$group5"
            if [ $? -eq 0 ] ; then
            	message "ERROR - \"$group5\" still have members and should not - failed on $FULLHOSTNAME"
            else
            	message "\"$group5\" no longer has any members."
            fi

           ssh root@$FULLHOSTNAME "ipa hostgroup-show \"$group5\"" > $tmpfile
           cat $tmpfile | grep "member:"
           if [ $? -eq 0 ] ; then
           	message "ERROR - \"$group4\" still has members and should not - failed on $FULLHOSTNAME"
           else
          	 message "\"$group4\" no longer has any members."
           fi

        done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_009()
{
        myresult=PASS
        errorcode=162
        message "START $tet_thistest: Negative - add duplicate host group"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
             if [ "$s" == "M1" ]; then
                eval_vars $s

                # check return code
                ssh root@$FULLHOSTNAME "ipa hostgroup-add --description="testing" \"$group5\""
                ret=`echo $?`
                if [ $ret -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-add.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa hostgroup-add returned expected code trying to add duplicate host."
                fi
             fi
        done
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_010()
{
        myresult=PASS
        errorcode=161
	mygroup="Bad Group"
        message "START $tet_thistest: Negative - Host Group Doesn't Exist"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
             if [ "$s" == "M1" ]; then
                eval_vars $s

                # check return code
                ssh root@$FULLHOSTNAME "ipa hostgroup-del \"$mygroup\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-del.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa hostgroup-del returned expected code trying to delete a host group that doesn't exist."
                fi

                ssh root@$FULLHOSTNAME "ipa hostgroup-find \"$mygroup\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-find.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa hostgroup-find returned expected code trying to find a host group that doesn't exist."
                fi


                ssh root@$FULLHOSTNAME "ipa hostgroup-show \"$mygroup\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-show.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa hostgroup-show returned expected code trying to show a host group that doesn't exist."
                fi

                ssh root@$FULLHOSTNAME "ipa hostgroup-mod --description="testing" \"$mygroup\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-mod.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa hostgroup-mod returned expected code trying to modify a host group that doesn't exist."
                fi

                ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hostgroups=$group1 \"$mygroup\""

                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-add-member.  expected: $errorcode got: $?"
                        myresult=FAIL
                else
                        message "ipa hostgroup-add-member returned expected code trying to adding member to a host group that doesn't exist."
                fi

                ssh root@$FULLHOSTNAME "ipa hostgroup-remove-member --hostgroups=$group1 \"$mygroup\""
                if [ $? -ne $errorcode ] ; then
                        message "ERROR - unexpected return code from ipa hostgroup-remove-member.  expected: $errorcode got: $?"
                        myresult=FAIL
                else 
                        message "ipa hostgroup-remove-member returned expected code trying to removing a member from a host group that doesn't exist."
                fi
             fi
        done
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_011()
{
        myresult=PASS
        errorcode=100
	tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Negative - Host Group as Member to itself"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
	s="M1"
	eval_vars $s 

	ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hostgroups=$group1 \"$group1\""
	# check error code
        if [ $? -ne $errorcode ] ; then
             message "ERROR - unexpected return code from ipa hostgroup-add-member.  expected: $errorcode got: $?"
             myresult=FAIL
        else
             message "ipa hostgroup-add-member returned expected code trying to adding self as member to a host group"
        fi

	# verify host group is not a member of itself
	ssh root@$FULLHOSTNAME "ipa hostgroup-show \"$group1\"" > $tmpfile
        cat $tmpfile | grep "${ugrplist[$h]}"
        if [ $? -ne 0 ] ; then
             message "ERROR - \"${ugrplist[$h]}\" is not a member of \"${grouplist[$i]}\" and should be - failed on $FULLHOSTNAME"
             myresult=FAIL
        else
             message "\"${ugrplist[$h]}\" is a member of \"${grouplist[$i]}\" - verified on $FULLHOSTNAME"         
       fi
	
	rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_012()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Delete Host group that has members"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        s="M1"
        eval_vars $s

        i=0
        while [ $i -lt 2 ] ; do

          # add members to two host groups
           ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hosts=\"${hostlist[0]}\" --groups=\"${ugrplist[0]}\" --hostgroups=\"${grouplist[2]}\" \"${grouplist[$i]}\""
            if [ $? -ne 0 ] ; then
                message "ERROR - ipa hostgroup-add-member to \"${grouplist[$i]}\" failed on $FULLHOSTNAME"
                myresult=FAIL
            fi

        # verify membership
          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
          cat $tmpfile | grep ${hostlist[0]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${hostlist[0]}\" should be a member of \"${grouplist[$i]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${hostlist[0]}\" is a member of \"${grouplist[$i]}\""
          fi

          cat $tmpfile | grep ${ugrplist[0]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${ugrplist[0]}\" should be a member of \"${grouplist[$i]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${ugrplist[0]}\" is a member of \"${grouplist[$i]}\""
          fi

          cat $tmpfile | grep ${grouplist[2]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${grouplist[2]}\" should be a member of \"${grouplist[$i]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${grouplist[2]}\" is a member of \"${grouplist[$i]}\""
          fi

          ((i=$i+1))

	done

  	# delete one of the host groups
        ssh root@$FULLHOSTNAME "ipa hostgroup-del \"${grouplist[0]}\""
        if [ $? -ne 0 ] ; then
               message "ERROR - ipa hostgroup-del \"${grouplist[0]}\" failed on $FULLHOSTNAME rc:$?"
               myresult=FAIL
        fi

	# verify the host group was delete
        ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[0]}\""
        if [ $? -ne 161 ] ; then
               message "ERROR - ipa hostgroup-show \"${grouplist[0]}\" return code not as expected on $FULLHOSTNAME got:$? expected: 161"
               myresult=FAIL
        else
               message "\"${grouplist[0]}\" deleted successfully."
        fi

	# verify memberships for the other host group
          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[1]}\"" > $tmpfile
          cat $tmpfile | grep ${hostlist[0]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${hostlist[0]}\" should be a member of \"${grouplist[1]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${hostlist[0]}\" is a member of \"${grouplist[1]}\""
          fi

          cat $tmpfile | grep ${ugrplist[0]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${ugrplist[0]}\" should be a member of \"${grouplist[1]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${ugrplist[0]}\" is a member of \"${grouplist[1]}\""
          fi

          cat $tmpfile | grep ${grouplist[2]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${grouplist[2]}\" should be a member of \"${grouplist[1]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${grouplist[2]}\" is a member of \"${grouplist[1]}\""
          fi

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_013()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Delete Host that is a member of host groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        s="M1"
        eval_vars $s

        # add host to another host group
        ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hosts=${hostlist[0]} \"${grouplist[2]}\""
        if [ $? -ne 0 ] ; then
                message "ERROR - ipa hostgroup-add-member host \"${hostlist[0]}\" to \"${grouplist[2]}\" failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

        i=1
        while [ $i -lt 3 ] ; do

        # verify membership
          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
          cat $tmpfile | grep ${hostlist[0]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${hostlist[0]}\" should be a member of \"${grouplist[$i]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${hostlist[0]}\" is a member of \"${grouplist[$i]}\""
          fi
          ((i=$i+1))

        done

        # now delete the host
        ssh root@$FULLHOSTNAME "ipa host-del ${hostlist[0]}"
        if [ $? -ne 0 ] ; then
               message "ERROR - ipa host-del \"${hostlist[0]}\" failed on $FULLHOSTNAME rc:$?"
               myresult=FAIL
	else
	       message "\"${hostlist[0]}\" deleted successfully."
        fi

        # verify the host groups do not have host as member - host was removed as member

        i=1
        while [ $i -lt 3 ] ; do

          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
          cat $tmpfile | grep \"${hostlist[0]}\"
          if [ $? -eq 0 ] ; then
              message "ERROR - \"${grouplist[$i]}\" still has \"${hostlist[0]}\" as member - failed on $FULLHOSTNAME"
          else
              message "\"${hostlist[0]}\" no longer member of\"${grouplist[$i]}\"."
          fi
	  ((i=$i+1))

       done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_014()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Delete user group that is a member of host groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        s="M1"
        eval_vars $s

        # add user group to another host group
        ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --groups=${ugrplist[0]} \"${grouplist[2]}\""
        if [ $? -ne 0 ] ; then
                message "ERROR - ipa hostgroup-add-member host \"${ugrplist[0]}\" to \"${grouplist[2]}\" failed on $FULLHOSTNAME"
                myresult=FAIL
        fi

        i=1
        while [ $i -lt 3 ] ; do

        # verify membership
          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
          cat $tmpfile | grep ${ugrplist[0]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${ugrplist[0]}\" should be a member of \"${grouplist[$i]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${ugrplist[0]}\" is a member of \"${grouplist[$i]}\""
          fi
          ((i=$i+1))

        done

        # now delete the user group
        ssh root@$FULLHOSTNAME "ipa group-del ${ugrplist[0]}"
        if [ $? -ne 0 ] ; then
               message "ERROR - ipa group-del \"${ugrplist[0]}\" failed on $FULLHOSTNAME rc:$?"
               myresult=FAIL
	else
	       message "\"${ugrplist[0]}\" deleted successfully."
        fi

        # verify the host groups do not have user group as member - host was removed as member
        i=1
        while [ $i -lt 3 ] ; do

          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\"" > $tmpfile
          cat $tmpfile | grep \"${ugrplist[0]}\"
          if [ $? -eq 0 ] ; then
              message "ERROR - \"${grouplist[$i]}\" still has \"${ugrplist[0]}\" as member - failed on $FULLHOSTNAME"
          else
              message "\"${ugrplist[0]}\" no longer member of\"${grouplist[$i]}\"."
          fi
	  ((i=$i+1))

       done

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

hostgrpcli_015()
{
        myresult=PASS
        tmpfile=$TET_TMP_DIR/members.txt
        message "START $tet_thistest: Delete host group that is a member of host groups"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        s="M1"
        eval_vars $s

        # add host group to another host group
        ssh root@$FULLHOSTNAME "ipa hostgroup-add-member --hostgroups=\"${grouplist[2]}\" \"${grouplist[3]}\""
        if [ $? -ne 0 ] ; then
                message "ERROR - ipa hostgroup-add-member \"${grouplist[2]}\" to \"${grouplist[3]}\" failed on $FULLHOSTNAME: rc: $?"
                myresult=FAIL
        fi

        # verify membership
          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[1]}\"" > $tmpfile
          cat $tmpfile | grep ${grouplist[2]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${grouplist[2]}\" should be a member of \"${grouplist[1]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL
          else
                message "\"${grouplist[2]}\" is a member of \"${grouplist[1]}\""
          fi

          ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[3]}\"" > $tmpfile
          cat $tmpfile | grep ${grouplist[2]}
          if [ $? -ne 0 ] ; then
                message "ERROR - \"${grouplist[2]}\" should be a member of \"${grouplist[3]}\" but is not - failed on $FULLHOSTNAME"
                myresult=FAIL 
          else
                message "\"${grouplist[2]}\" is a member of \"${grouplist[3]}\""
          fi

        # now delete the host group
        ssh root@$FULLHOSTNAME "ipa hostgroup-del ${grouplist[2]}"
        if [ $? -ne 0 ] ; then
               message "ERROR - ipa hostgroup-del \"${grouplist[2]}\" failed on $FULLHOSTNAME rc:$?"
               myresult=FAIL
	else
		message " \"${grouplist[2]}\" deleted successfully."
        fi

        # verify the host groups do not have host group as member - host was removed as member
        ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[1]}\"" > $tmpfile
        cat $tmpfile | grep ${grouplist[2]}
        if [ $? -eq 0 ] ; then
            message "ERROR - \"${grouplist[1]}\" still has \"${grouplist[2]}\" as member - failed on $FULLHOSTNAME"
        else
            message "\"${grouplist[2]}\" no longer member of\"${grouplist[1]}\"."
        fi

        ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[3]}\"" > $tmpfile
        cat $tmpfile | grep ${grouplist[2]}
        if [ $? -eq 0 ] ; then
            message "ERROR - \"${grouplist[3]}\" still has \"${grouplist[2]}\" as member - failed on $FULLHOSTNAME"
        else
            message "\"${grouplist[2]}\" no longer member of\"${grouplist[3]}\"."
        fi

        rm -rf $tmpfile
        result $myresult
        message "END $tet_thistest"
}

cleanup()
{
        myresult=PASS
        message "START $tet_thistest: Cleanup"
        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        for s in $SERVERS; do
                if [ "$s" == "M1" ]; then
                	eval_vars $s
                   	i=0
		   	while [ $i -lt ${#grouplist[@]} ] ; do
                        	ssh root@$FULLHOSTNAME "ipa hostgroup-del \"${grouplist[$i]}\""

                        	# check return code
                        	ssh root@$FULLHOSTNAME "ipa hostgroup-show \"${grouplist[$i]}\""
                        	if [ $? -ne 161 ] ; then
                                  message "ERROR - ipa hostgroup-show \"${grouplist[$i]}\" return code not as expected on $FULLHOSTNAME got:$? expected: 161"
                                  myresult=FAIL
                        	else
                                  message "\"${grouplist[$i]}\" does not exist."
                        	fi
				((i=$i+1))
                  	done

		  	i=0
		  	while [ $i -lt ${#hostlist[@]} ] ; do
                        	ssh root@$FULLHOSTNAME "ipa host-del \"${hostlist[$i]}\""

                        	# check return code
                        	ssh root@$FULLHOSTNAME "ipa host-show \"${hostlist[$i]}\""
                        	if [ $? -ne 161 ] ; then
                                  message "ERROR - ipa host-show \"${hostlist[$i]}\" return code not as expected on $FULLHOSTNAME got:$? expected: 161"
                                  myresult=FAIL
                        	else
                                  message "\"${hostlist[$i]}\" does not exist."
                        	fi
				((i=$i+1))
		  	done

                        i=0
                        while [ $i -lt ${#ugrplist[@]} ] ; do
                                ssh root@$FULLHOSTNAME "ipa group-del \"${ugrplist[$i]}\""

                                # check return code
                                ssh root@$FULLHOSTNAME "ipa group-show \"${ugrplist[$i]}\""
                                if [ $? -ne 161 ] ; then
                                  message "ERROR - ipa group-show \"${ugrplist[$i]}\" return code not as expected on $FULLHOSTNAME got:$? expected: 161"
                                  myresult=FAIL
                                else
                                  message "\"${ugrplist[$i]}\" does not exist."
                                fi
                                ((i=$i+1))
                        done

                fi
        done

        result $myresult
        message "END $tet_thistest"
}

bug499731()
{
        myresult=PASS
        message "START $tet_thistest: Adding host to host group causes memberOf errors in DS Log"

        if [ "$DSTET_DEBUG" = "y" ]; then set -x; fi
        s="M1"
	eval_vars $s
		  i=0
		  while [ $i -lt ${#hostlist[@]} ] ; do
			# search the log for the message
			inst=`echo $REALM | sed 's/\./-/g'`
			errmsg="Entry \\\"cn=${hostlist[$i]},cn=computers,cn=accounts,$BASEDN\\\" -- attribute \\\"memberOf\\\" not allowed"
			message "Looking for \"$errmsg\" in Directory Server Log"
			dirlog="/var/log/dirsrv/slapd-$inst/errors"
			ret=`ssh root@$FULLHOSTNAME "grep -Fc \"${errmsg}\" -- \"${dirlog}\""` 
			if [ $ret -ne 0 ] ; then
				message "ERROR - bug 499731 still exists or has returned!"
				message "Found $ret occurences of the error in the DS Log for \"${hostlist[$i]}\""
				myresult=FAIL
			else
				message "Found $ret occurences of the error in the DS Log for \"${hostlist[$i]}\""
			fi
			((i=$i+1))
		   done

        result $myresult
        message "END $tet_thistest"
}


######################################################################
#
. $TESTING_SHARED/instlib.ksh
. $TESTING_SHARED/shared.ksh
. $TET_ROOT/lib/ksh/tcm.ksh

