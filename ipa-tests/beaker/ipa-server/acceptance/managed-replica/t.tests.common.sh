# Tests to ensure that all of the servers are avaliable 
check_list()
{
	ret=0
	hostsimple=$(echo $MASTER | cut -d\. -f1)	
	ipa-replica-manage --password=Secret123 list | grep $hostsimple
	if [ $? -ne 0 ]; then
		ret=1;
	fi
	for slave in $SLAVE
	do
		hostsimple=$(echo $slave | cut -d\. -f1)	
		ipa-replica-manage --password=Secret123 list | grep $hostsimple
		if [ $? -ne 0 ]; then
			ret=1;
		fi

	done
return $ret
	
}

