#######################################
# lib.user-cli.sh
#######################################

# functions used in user-cli test
Kinit()
{
#return 0=success
#return 1=failed
    local user=$1
    local password=$2
    rlLog "kinit as user [$user] with password [$password]"
    rlRun "echo $password | kinit $user"
    if [ $? -ne 0 ];then
        rlLog "kinit as [$user] failed"
        return 1
    else
        if klist | grep $user
        then
            rlLog "principal found, kinit success"
            return 0
        else
            rlLog "kinit success, but no principal found"
            return 1
        fi
    fi
} #Kinit

Kdestroy()
{
#return 0=success
#return 1=failed
    rlLog "clean up all kinit ticket by kdestroy"
    rlRun "/usr/kerberos/bin/kdestroy  "
    if [ $? -ne 0 ];then
        rlLog "kdestroy failed"
        return 1
    else
        rlLog "kdestroy success"
        return 0
    fi
} #Kdestroy

SetUserPassword()
{
    TET_TMP_DIR="/tmp"
	if [ "$1" = "" ]; then
		echo 'ERROR - You must call SetUserPassword with a username in the $2 position'
		return 1;
	fi 

	if [ "$2" = "" ]; then
		echo 'ERROR - You must call SetUserPassword with a password in the $3 position'
		return 1;
	fi 
    rm -f $TET_TMP_DIR/SetUserPassword.exp
    echo 'set timeout 60
set send_slow {1 .1}' > $TET_TMP_DIR/SetUserPassword.exp
	echo "spawn ipa passwd $2" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'match_max 100000' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'sleep 7' >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'sleep 4' >> $TET_TMP_DIR/SetUserPassword.exp
	echo "send -s -- \"$3\"" >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/SetUserPassword.exp
	echo 'expect eof ' >> $TET_TMP_DIR/SetUserPassword.exp

	/usr/bin/expect /tmp/SetUserPassword.exp > /tmp/SetUserPassword-output.txt
	ret=$?
	if [ $ret != 0 ]; then
		echo "ERROR - Setting the password of user $1, password of $2 failed";
		return 1;
	fi
	return 0;
} #SetUserPassword

KinitAs_local()
{
    TET_TMP_DIR="/tmp"
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call KinitAs with a username in the $2 position'
		return 1;
	fi 
	if [ "$3" = "" ]; then
		echo 'ERROR - You must call KinitAs with a password in the $3 position'
		return 1;
	fi 
	username=$1
	password=$2
    rm -f $TET_TMP_DIR/kinit.exp
    echo 'set timeout 30
set force_conservative 0
set send_slow {1 .1}' > $TET_TMP_DIR/kinit.exp
	echo "OS is $OS"
	echo "spawn /usr/kerberos/bin/kinit -V $username" >> $TET_TMP_DIR/kinit.exp
	echo 'match_max 100000' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$password\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	kdestroy
    /usr/bin/expect /tmp/kinit.exp
	if [ $? != 0 ]; then
		echo "ERROR - kinit as user $username, password of $password failed";
		return 1;
	fi

	echo "This is a klist on the machine we just kinited on, it should show that user $username is kinited"
	klist > $TET_TMP_DIR/KinitAs-output.txt
	grep $username $TET_TMP_DIR/KinitAs-output.txt

	if [ $? -ne 0 ]; then
        kdestroy
        /usr/bin/expect /tmp/kinit.exp
	    if [ $? != 0 ]; then
	    	echo "ERROR - kinit as user $username, password of $password failed";
			return 1
    	fi

	    klist > $TET_TMP_DIR/KinitAs-output.txt
	    grep $username $TET_TMP_DIR/KinitAs-output.txt
	    if [ $? -ne 0 ]; then
	    	echo "ERROR - error in KinitAs, kinit didn't appear to work, $username not found in $TET_TMP_DIR/KinitAs-output.txt"
	    	echo "contents of $TET_TMP_DIR/KinitAs-output.txt:"
	    	cat $TET_TMP_DIR/KinitAs-output.txt
	    	return 1
	    fi
	else
	    cat $TET_TMP_DIR/KinitAs-output.txt
	fi

	return 0;

} #KinitAs

KinitAsFirst_local()
{
    TET_TMP_DIR="/tmp"
	if [ "$1" = "" ]; then
		echo 'ERROR - You must call KinitAs with a username in the $2 position'
		return 1;
	fi 
	if [ "$2" = "" ]; then
		echo 'ERROR - You must call KinitAs with a password in the $3 position'
		return 1;
	fi 
	username=$1
	password=$2
	newpassword=$3
    rm -f $TET_TMP_DIR/kinit.exp
    echo 'set timeout 30
set send_slow {1 .1}' > $TET_TMP_DIR/kinit.exp
	echo "OS is $OS"
	echo "spawn /usr/kerberos/bin/kinit -V $username" >> $TET_TMP_DIR/kinit.exp
	echo 'match_max 100000' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$password\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$newpassword\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect "*: "' >> $TET_TMP_DIR/kinit.exp
	echo 'sleep .5' >> $TET_TMP_DIR/kinit.exp
	echo "send -s -- \"$newpassword\"" >> $TET_TMP_DIR/kinit.exp
	echo 'send -s -- "\r"' >> $TET_TMP_DIR/kinit.exp
	echo 'expect eof ' >> $TET_TMP_DIR/kinit.exp

	kdestroy
    /usr/bin/expect /tmp/kinit.exp > /tmp/KinitAsFirst-out.txt
	if [ $? != 0 ]; then
		echo "ERROR - kinit as user $username, password of $password, newpassword of $newpassword failed";
		return 1;
	fi
	
	echo "This is a klist on the machine we just kinited on, it should show that user $username is kinited"
	klist > $TET_TMP_DIR/KinitAsFirst-output.txt
	cat $TET_TMP_DIR/KinitAsFirst-output.txt
	grep $2 $TET_TMP_DIR/KinitAsFirst-output.txt
	if [ $? -ne 0 ]; then
		echo "oops, that didn't work. Re-syncing everything and trying again"
		kdestroy
        /usr/bin/expect /tmp/kinit.exp > /tmp/KinitAsFirst-out.txt
		if [ $? != 0 ]; then
			echo "ERROR - kinit as user $username, password of $password, newpassword of $newpassword failed";
			return 1;
		fi
		echo "This is a klist on the machine we just kinited on, it should show that user $username is kinited"
		klist > $TET_TMP_DIR/KinitAsFirst-output.txt
		cat $TET_TMP_DIR/KinitAsFirst-output.txt
		grep $username $TET_TMP_DIR/KinitAsFirst-output.txt
		if [ $? -ne 0 ]; then
			echo "ERROR - error in KinitAsFirst, kinit didn't appear to work, $username not found in $TET_TMP_DIR/KinitAsFirst-output.txt"
			echo "contents of $TET_TMP_DIR/KinitAsFirst-output.txt:"
			cat $TET_TMP_DIR/KinitAsFirst-output.txt
			return 1;
		fi
	else 
		cat $TET_TMP_DIR/KinitAsFirst-output.txt
	fi

	return 0
} #KinitAsFirst
