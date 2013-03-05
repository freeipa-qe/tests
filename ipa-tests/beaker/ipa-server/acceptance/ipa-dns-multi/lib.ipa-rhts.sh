# A set of experimental tools to get a alternate rhts sync going on

export IPARHTSDIR="/var/www/html/iparhtsdir"

setup_iparhts_sync()
{
	# Make sure apache is installed
	yum -y install httpd
	rm -Rf $IPARHTSDIR
	mkdir -p $IPARHTSDIR
	chmod 755 $IPARHTSDIR
	/etc/init.d/httpd restart
	systemctl restart httpd.service
}

iparhts-sync-set()
{
	rlLog "NOTICE - touching $IPARHTSDIR/$2 for RHTS sync"
	touch $IPARHTSDIR/$2
	chmod 755 $IPARHTSDIR/$2
}

iparhts-sync-block()
{
#iparhts-sync-set -s READY_REPLICA1 $BEAKERMASTER
	rlLog "Blocking waiting for $3 to post state $2"
	done=0;
	while [ $done -eq 0 ]; do
		rlLog "Attempting to get http://$3/iparhtsdir/$2"
		wget http://$3/iparhtsdir/$2
		if [ $? -eq 0 ]; then 
			rlLog "Success! Got $2 from $3. Proceeding."
			done=1;
		else
			rlLog "WAITING - Get of http://$3/iparhtsdir/$2 failed. Sleeping 60 sec"
			sleep 60
		fi
	done
}
