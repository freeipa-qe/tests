#####################
#  GLOBALS	    #
#####################
HTTPCFGDIR="/etc/httpd/conf"
HTTPCERTDIR="$HTTPCFGDIR/alias"
HTTPPRINC="HTTP/$HOSTNAME"
HTTPKEYTAB="$HTTPCFGDIR/$HOSTNAME.keytab"
HTTPKRBCFG="/etc/httpd/conf.d/krb.conf"

FAKEHOSTNAME="managedby-fakehost.testrelm"
FAKEHOSTREALNAME="managedby-fakehost.idm.lab.bos.redhat.com"
FAKEHOSTNAMEIP="10.16.98.239"
FAKEHOSTKEYTABFILE="/dev/shm/$FAKEHOSTNAME.host.keytab"
CLIENTKEYTABFILE="/dev/shm/$CLIENT.host.keytab"

echo " HTTP configuration directory:  $HTTPCFGDIR"
echo " HTTP certificate directory:  $HTTPCERTDIR"
echo " HTTP krb configuration file: $HTTPKRBCFG"
echo " HTTP principal:  $HTTPPRINC"
echo " HTTP keytab: $HTTPKEYTAB"

######################
# test suite         #
######################
ipa-managedbyfunctionaltests()
{
    managedby_server_tests
    cleanup_managedby
} 

######################
# SETUP              #
######################

ipa-managedbyfunctionaltestssetup()
{
	kdestroy
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"

	# create a host to be used by the client. 
#	echo "running: ipa dnsrecord-add 98.16.10.in-addr.arpa. 239 --ptr-rec $FAKEHOSTNAME."
#	ipa dnsrecord-add 98.16.10.in-addr.arpa. 239 --ptr-rec $FAKEHOSTNAME.	
	echo "running: ipa host-add --ip-address=$FAKEHOSTNAMEIP $FAKEHOSTNAME"
	ipa host-add --ip-address=$FAKEHOSTNAMEIP $FAKEHOSTNAME
	
	rlPhaseStartTest "Add managedby agreement for this host"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa host-add-managedby --hosts=$MASTER $CLIENT" 0 "Adding a managedby agreement for the MASTER of the client"
		rlRun "ipa host-find $CLIENT | grep $MASTER" 0 "Making sure that $MASTER seems to exist on the definition of $CLIENT"
	rlPhaseEnd

	rlPhaseStartTest "Add managedby agreement for the client to $FAKEHOSTNAME"
		rlRun "ipa host-add-managedby --hosts=$CLIENT $FAKEHOSTNAME" 0 "Adding a managedby agreement for the MASTER of the client"
		rlRun "ipa host-find $FAKEHOSTNAME | grep $CLIENT" 0 "Making sure that $CLIENT seems to exist on the definition of $FAKEHOSTNAME"
	rlPhaseEnd

	rlPhaseStartTest "Create a service to CLIENT to test with later"
		rlRun "ipa service-add test/$CLIENT" 0 "Added a test service to the CLIENT"
		rlRun "ipa service-find test/$CLIENT" 0 "Ensure that the service got added properly"
	rlPhaseEnd

	rlPhaseStartTest "Create a services to FAKEHOST to test with later"
		rlRun "ipa service-add test/$FAKEHOSTNAME" 0 "Added a test service to the FAKEHOST"
		rlRun "ipa service-find test/$FAKEHOSTNAME" 0 "Ensure that the service got added properly"
	rlPhaseEnd

	rlPhaseStartTest "add a managedby service agreement for the master to the test/client serivce"
		rlRun "ipa service-add-host --hosts=$MASTER test/$CLIENT" 0 "Adding $MASTER to the clients service"
		rlRun "ipa service-add-host --hosts=$MASTER test/$CLIENT | grep 'member host' | grep $MASTER" 0 "Verify that the master seems to be in the list for the client service"
	rlPhaseEnd

	rlPhaseStartTest "Make some keytabs for later testing"
		rm -f $FAKEHOSTKEYTABFILE
		rm -f $CLIENTKEYTABFILE
		rlRun "ipa-getkeytab -s $MASTER -k $FAKEHOSTKEYTABFILE -p host/$FAKEHOSTNAME" 0 "get the host keytab for the fake host"
		rlRun "ipa-getkeytab -s $MASTER -k $CLIENTKEYTABFILE -p host/$CLIENT" 0 "get the host keytab for the client"
	rlPhaseEnd

}

managedby_server_tests()
{
	rlPhaseStartTest "Negitive test case to try binding as the CLIENTs principal"
		kdestroy
		rlRun "kinit -kt /etc/krb5.keytab host/$CLIENT" 1 "Bind as the host principal for CLIENT, this should return 1"
		rlRun "klist | grep host/$CLIENT" 1 "make sure we are not bound as the CLIENT host principal"
	rlPhaseEnd

	rlPhaseStartTest "bind as the MASTERs principal"
		kdestroy
		rlRun "kinit -kt /etc/krb5.keytab host/$MASTER" 0 "Bind as the host principal for this host"
		rlRun "klist | grep host/$MASTER" 0 "make sure we seem to be bound as the MASTER principal"
	rlPhaseEnd
	
	rlPhaseStartTest "try to create a keytab for a service that we should not be able to"
		file="/dev/shm/fakehostprincipal.keytab"
		rlRun "ipa-getkeytab -s $MASTER -k $file -p test/$FAKEHOSTNAME" 9 "Try to create a keytab for a service that we shouldn't have access to. running ipa-getkeytab -s $MASTER -k $file -p test/$FAKEHOSTNAME"
	rlPhaseEnd

	file="/dev/shm/clientprincipal.keytab"
	hostfile="/dev/shm/clienthostprincipal.keytab"

	rlPhaseStartTest "try to create a keytab for a service that we should be able to"
		rlRun "ipa-getkeytab -s $MASTER -k $file -p test/$CLIENT" 0 "Try to create a keytab for a service that we should have access to by running ipa-getkeytab -s $MASTER -k $file -p test/$CLIENT"
		rlRun "ipa-getkeytab -s $MASTER -k $hostfile -p host/$CLIENT" 0 "Try to create a keytab for a service that we should have access to by running ipa-getkeytab -s $MASTER -k $file -p test/$CLIENT"
		rlRun "grep $CLIENT $file" 0 "Make sure that the CLIENT hostname appears to be in the new keytab"
	rlPhaseEnd

	rlPhaseStartTest "ensure that we can kinit as the gotten keytabs"
		rlRun "kinit -kt $hostfile host/$CLIENT" 0 "Make sure we can kinit as the keytab that we got from the client"
		kdestroy
		kinit -kt /etc/krb5.keytab host/$MASTER
	rlPhaseEnd

	RANDOM=/dev/shm/random.txt
	echo 'asjkfavi byrwebh8959aevut890artyariutainawer8turtvuntiohufyav89ra7e4597346g7q35gqhv79976856f0qw47tbawvranofiau db8fgaeru sdboadfuaidfgy apvudfuas!bio fu' > $RANDOM
	PWDFILE=/dev/shm/pwfile.txt
	echo "Secret123" > $PWDFILE
	rlPhaseStartTest "create a csr for the client and sign it using the managed by agreement"
		certdir=/dev/shm/clientdb
		rm -Rf $certdir
		mkdir $certdir
		cd $certdir
		echo "running certutil -R -s 'CN=$CLIENT,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $CLIENT.csr"
		rlRun "certutil -R -s 'CN=$CLIENT,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $CLIENT.csr" 0 "Create a csr for the client"
		rlRun "ipa cert-request --principal=host/$MASTER@$RELM $CLIENT.csr" 0 "Sign the client CSR"
	rlPhaseEnd

	rlPhaseStartTest "Negitive test case to ensur"
		certdir=/dev/shm/fakehostdb
		rm -Rf $certdir
		mkdir $certdir
		cd $certdir
		rlRun "certutil -R -s 'CN=$FAKEHOSTNAME,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $FAKEHOSTNAME.csr" 0 "Create a csr for the fakehost"
		rlRun "ipa cert-request --principal=host/$MASTER@$RELM $FAKEHOSTNAME.csr" 1 "Make sure that we could not sigh the csr"
	rlPhaseEnd

}

managedby_client_tests()
{
	rlPhaseStartTest "Negitive test case to try binding as the MASTERs principal"
		kdestroy
		rlRun "kinit -kt /etc/krb5.keytab host/$MASTER" 1 "Bind as the host principal for MASTER, this should return 1"
		rlRun "klist | grep host/$MASTER" 1 "make sure we are not bound as the MASTER host principal"
	rlPhaseEnd

	rlPhaseStartTest "bind as the CLIENTs principal"
		kdestroy
		rlRun "kinit -kt /etc/krb5.keytab host/$CLIENT" 0 "Bind as the host principal for this host"
		rlRun "klist | grep host/$CLIENT" 0 "make sure we seem to be bound as the CLIENT principal"
	rlPhaseEnd
	
	rlPhaseStartTest "try to create a keytab for a service that we should be able to"
		file="/dev/shm/fakehostprincipal.keytab"
		rlRun "ipa-getkeytab -s $CLIENT -k $file -p test/$FAKEHOSTNAME" 0 "Try to create a keytab for a service that we should have access to. running ipa-getkeytab -s $CLIENT -k $file -p test/$FAKEHOSTNAME"
	rlPhaseEnd

	file="/dev/shm/masterprincipal.keytab"

	rlPhaseStartTest "try to create a keytab for a service that we should not be able to"
		rlRun "ipa-getkeytab -s $CLIENT -k $file -p test2/$MASTER" 9 "Try to create a keytab for a service that we should inot have access to by running ipa-getkeytab -s $MASTER -k $file -p test/$MASTER"
		rlRun "grep $MASTER $file" r10 "Make sure that the CLIENT hostname appears to be in the new keytab"
	rlPhaseEnd

	rlPhaseStartTest "ensure that we can not kinit as the gotten keytabs"
		rlRun "kinit -kt $file test2/$master" 1 "Make sure we can not kinit as the keytab that we got from the client"
		kdestroy
		kinit -kt /etc/krb5.keytab host/$CLIENT
	rlPhaseEnd

	RANDOM=/dev/shm/random.txt
	echo 'asjkfavi byrwebh8959aevut890artyariutainawer8turtvuntiohufyav89ra7e4597346g7q35gqhv79976856f0qw47tbawvranofiau db8fgaeru sdboadfuaidfgy apvudfuas!bio fu' > $RANDOM
	PWDFILE=/dev/shm/pwfile.txt
	echo "Secret123" > $PWDFILE
	rlPhaseStartTest "create a csr for the client and sign it using the managed by agreement"
		certdir=/dev/shm/clientdb
		rm -Rf $certdir
		mkdir $certdir
		cd $certdir
		echo "running certutil -R -s 'CN=$CLIENT,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $certdir/$CLIENT.csr"
		rlRun "certutil -R -s 'CN=$CLIENT,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $certdir/$CLIENT.csr" 0 "Create a csr for the client"
		rlRun "ipa cert-request --principal=host/$CLIENT@$RELM $certdir$CLIENT.csr" 0 "Sign the client CSR"
	rlPhaseEnd

	rlPhaseStartTest "create a csr for the client and sign it using the managed by agreement"
		certdir=/dev/shm/fakehostdb
		rm -Rf $certdir
		mkdir $certdir
		cd $certdir
		echo "running certutil -R -s 'CN=$FAKEHOSTNAME,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $certdir/$FAKEHOSTNAME.csr"
		rlRun "certutil -R -s 'CN=$FAKEHOSTNAME,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $certdir/$FAKEHOSTNAME.csr" 0 "Create a csr for the client"
		rlRun "ipa cert-request --principal=host/$FAKEHOSTNAME@$RELM $certdir/$FAKEHOSTNAME.csr" 0 "Sign the client CSR"
	rlPhaseEnd

	rlPhaseStartTest "Negitive test case to ensur"
		certdir=/dev/shm/fakehostdb
		rm -Rf $certdir
		mkdir $certdir
		cd $certdir
		rlRun "certutil -R -s 'CN=$FAKEHOSTNAME,O=$RELM' -a -d . -z $RANDOM -f $PWDFILE >> $FAKEHOSTNAME.csr" 0 "Create a csr for the fakehost"
		rlRun "ipa cert-request --principal=host/$MASTER@$RELM $FAKEHOSTNAME.csr" 1 "Make sure that we could not sigh the csr"
	rlPhaseEnd

}


cleanup_managedby()
{

	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
	file="/dev/shm/fakehostprincipal.keytab"
	rm -f $file
	file="/dev/shm/clientprincipal.keytab"
	rm -f $file
	ipa service-del test/$FAKEHOSTNAME
	ipa service-del test2/$FAKEHOSTNAME
	ipa service-del test/$CLIENT
	ipa host-remove-managedby --hosts=$MASTER $CLIENT
	ipa host-remove-managedby --hosts=$CLIENT $FAKEHOSTNAME
	ipa host-del $FAKEHOSTNAME
	echo Y | ipa dnsrecord-del 98.16.10.in-addr.arpa. 239
}

cleanup_http()
{
	rlPhaseStartTest "CLEANUP: HTTP Server"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		cd /etc/httpd/alias/
		# remove cert files
		rm -rf $HOSTNAME.csr ca.crt $HOSTNAME.crt

		# remove the certificates from the web server's database
		cd /etc/httpd/alias/
		rlRun "certutil -d . -D -n $HOSTNAME" 0 "Remove $HOSTNAME certificate from web server certificate database."
		rlRun "certutil -d . -D -n \"IPA CA\"" 0 "Remove IPA CA certificate from web server certificate database."	

		# delete the krb config file
		rlRun "rm -rf $HTTPKRBCFG" 0 "Delete the KRB config file"

		# restore nss.conf
		cp -f /etc/httpd/conf.d/nss.conf.orig /etc/httpd/conf.d/nss.conf
		rlRun "service httpd restart" 0 "Restarting apache server"
	rlPhaseEnd
}

cleanup_ipa_http()
{
	rlPhaseStartTest "CLEANUP: IPA Server - HTTP"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Get administrator credentials"
		rlRun "ipa user-del httpuser1" 0 "Delete the http test user"
		rlRun "service httpd stop" 0 "stopping apache server"
		rlRun "ipa-rmkeytab -p $HTTPPRINC -k $HTTPKEYTAB" 0 "removing http keytab"
		# delete keytab file
                rlRun "rm -rf $HTTPKEYTAB" 0 "Delete the HTTP keytab file"
		rlRun "ipa service-del $HTTPPRINC" 0 "Remove the HTTP service for this client host"
	rlPhaseEnd
}
	

