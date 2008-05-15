# Shared subs needed by most tests
# eval_vars(servername) - pass the servername to this sub to expand the servername into hostname, fullhostname, OS, etc.
# setup_ssh_keys(servername) - install a ssh key into the authorized_keys on the remote server. Create a local key if needed
#               It's okay to run this over and over again, if it's already been run, then this sub will complete without
#               interaction or error.
eval_vars()
{
        x=\$HOSTNAME_$1
        HOSTNAME=`eval echo $x`
        export HOSTNAME
        FULLHOSTNAME=`host $HOSTNAME | awk '{print $1}'`
        x=\$LDAP_PORT_$1
        LDAP_PORT=`eval echo $x`
        x=\$LDAPS_PORT_$1
        LDAPS_PORT=`eval echo $x`
        x=\$SERVER_INSTALL_DIR_$1
        INSTALL_DIR=`eval echo $x`
        x=\$CHANGELOG_DIR_$1
        CHANGELOG_DIR=`eval echo $x`
        if [ "$CHANGELOG_DIR" = "" ]; then
                CHANGELOG_DIR=$INSTALL_DIR/changelogdb
        fi
        x=\$FILE_${1}_IS_ALIVE
        FILE_SERVER_IS_ALIVE=`eval echo $x`
        x=\$REPLICA_ID_$1
        REPLICA_ID=`eval echo $x`
        x=\$$1_OS
        OS=`eval echo $x`
}

setup_ssh_keys()
{
	SID=$1
        eval_vars $SID
	# If there is no local ssh key, create one
	if [ ! -f ~/.ssh/id_dsa.pub ]; then
		echo "creating local key, DO NOT enter passwords here. Hit ENTER for all questions"
		if [ ! -d ~/.ssh ]; then
			mkdir ~/.ssh
			chmod 600 ~/.ssh
		fi
		ssh-keygen -t dsa
	fi
	
	if [ ! -f ~/.ssh/id_dsa.pub ]; then
		echo "ERROR! ssh-keygen didn't create a key into ~/.ssh/id_dsa.pub"
	fi

        if [ "$HOSTNAME" = "" ]; then
		echo "ERROR! eval_vars returned $HOSTNAME"
                return $rc
        fi
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo ""
	echo "setting up ssh key on host $HOSTNAME OS type is $OS"
	echo ""
	echo "When asked for a password, use the root password for host $FULLHOSTNAME"
	echo ""
	echo ""
	echo ""
	echo ""
	if [ $OS == "rhel" ]; then
		rm -f ./key-ssh.bash; echo "ssh $FULLHOSTNAME \"mkdir -p /root/.ssh;chmod 700 /root/.ssh\"" >> ./key-ssh.bash; bash ./key-ssh.bash
		echo ""
		echo "Great!, that seems to have worked, enter the same root password again"
		echo ""
		scp ~/.ssh/id_dsa.pub $FULLHOSTNAME:/root/.ssh/authorized_keys
	fi
	if [ $OS == "HPUX" ]; then
		rm -f ./key-ssh.bash; echo "ssh $FULLHOSTNAME \"mkdir -p /.ssh;chmod 700 /.ssh\"" >> ./key-ssh.bash; bash ./key-ssh.bash
		echo ""
		echo "Great!, that seems to have worked, enter the same root password again"
		echo ""
		scp ~/.ssh/id_dsa.pub $FULLHOSTNAME:/.ssh/authorized_keys
	fi
	if [ $OS == "solaris" ]; then
		rm -f ./key-ssh.bash; echo "ssh $FULLHOSTNAME \"mkdir -p /.ssh;chmod 700 /.ssh\"" >> ./key-ssh.bash; bash ./key-ssh.bash
		echo ""
		echo "Great!, that seems to have worked, enter the same root password again"
		echo ""
		scp ~/.ssh/id_dsa.pub $FULLHOSTNAME:/.ssh/authorized_keys
	fi

}

