##########################################
#   Variables 
#########################################
# Determine my IP address
currenteth=$(route | grep ^default | awk '{print $8}')

# get the ip address of that interface
#ipaddr=$(ifconfig $currenteth | grep inet\ addr | sed s/:/\ /g | awk '{print $3}')
ipaddr=$(hostname -i)
rlLog "Ip address is $ipaddr"
ipoc1=$(echo $ipaddr | cut -d\. -f1)
ipoc2=$(echo $ipaddr | cut -d\. -f2)
ipoc3=$(echo $ipaddr | cut -d\. -f3)
ipoc4=$(echo $ipaddr | cut -d\. -f4)

# Get the default routers ip, use that for the new ip for the fakehost
newfakehostip=`route -n | grep ^0 | awk '{print $2'}`
rlLog "IP is $ipoc1 . $ipoc2 . $ipoc3 . $ipoc4"

ipaddr="$MASTER."
zone="newzone"
email="ipaqar.redhat.com"
serial=2010010701
refresh=303
retry=101
expire=1202
minimum=33
ttl=55
badnum=12345678901234
loclat="121"
loclong="59"
loc="37 23 30.900 N $loclat $loclong 19.000 W 7.00m 100.00m 100.00m 2.00m"
naptr='100 10 U E2U+msg !^.*$!mailto:info@example.com! .'
naptrfind="info@example.com"

a="1.2.3.4"
ahost="1.testrelm.com"  #format must be specified as "PREFERENCE EXCHANGER" (see RFC 2230 for details)
multiarecord1="1.2.3.4"
multiarecord2="2.3.4.5"
aaaa="fec0:0:a10:6000:10:16ff:fe98:193"
aaaabad1="bada:aaaa:real:ly:bad:dude:extr:a"
aaaabad2="aaaa:bbbb:cccc:dddd:eeee:fffff"
afsdb="green.femto.edu."
certa="PGP 0 0"
certb="1 1 1"   # format must be specified as "TYPE KEY_TAG ALGORITHM CERTIFICATE_OR_CRL" (see RFC 4398 for details)
cert="F835EDA21E94B565716F"
cname="m.l.k."
dname="bar.$zone."
txt="none=1.2.3.4"
mx="mail.$DOMAIN"
ptroctet="4.4.4"
ptr="8"
ptrvalue="in.awesome.domain."
srva="0 100 389"
srv="why.go.here.com."
kxpref1="1234"
kxbadpref1="-1"
kxbadpref2="123345678"

# These values are all for creating the ptr zone
ptrzone="$ptroctet.in-addr.arpa."
# Bad ptr zone
bptrzone="1.2.3.in-addr.arpa."
pemail="ipaqar.redhat.com"
pserial=2010010799
prefresh=393
pretry=191
pexpire=1292
pminimum=39
pttl=59
pbadnum=12345678901234

# These values are for testing per zone permissions
managedZone="qa.testrelm.com"
managedZone1="dev.testrelm.com"
nonexistentZone="nonexistent.testrelm.com"

# These values are for testing persistent search
zonepsearch="westford.$DOMAIN"
newtxt="newip=5.6.7.8"
newertxt="newip=8.7.6.5"

#########################################
# Test Suite
#########################################

dnsacceptance()
{
   dnssetup
   dnsreplicaprepare
   dnszone
   dnsarecord
   dnsaaaarecord
   dnsafsbdrecord
   dnscnamerecord
   dnstxtrecord
   dnssvrrecord
   dnsmxrecord
   dnsptrzone
   dnsptrrecord
   dnsnaptrrecord
   dnsdnamerecord
   dnscertrecord
   dnslocrecord
   dnskxrecord
   dnszonepermission
   dnspsearch
   dnscleanup
}
#########################################
# Tests
#########################################

dnssetup()
{
    rlPhaseStartSetup "dns acceptance setup"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
    rlPhaseEnd
}

dnsreplicaprepare()
{

	rlPhaseStartTest "ipa-dns-replicaprepare-01 Add during replica prepare"
		let newip=$ipoc4+1
		rlLog "EXECUTING: ipa-replica-prepare -p $ADMINPW --ip-address=$newfakehostip newfakehost$newip.$DOMAIN"
		rlRun "ipa-replica-prepare -p $ADMINPW --ip-address=$newfakehostip newfakehost$newip.$DOMAIN" 0
	rlPhaseEnd


	rlPhaseStartTest "ipa-dns-replicaprepare-02 check forward ip of the replica was created in dns correctly with ping"
		sleep 10
		rlLog "EXECUTING: ping -c 1 newfakehost$newip.$DOMAIN"
		rlRun "ping -c 1 newfakehost$newip.$DOMAIN" 0 "Checking to ensure that the forward for the replica was created in dns"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-replicaprepare-03 check forward ip of replica was created in dns correctly with dig"
		rlLog "EXECUTING: dig newfakehost$newip.$DOMAIN | grep $newfakehostip"
		rlRun "dig newfakehost$newip.$DOMAIN | grep $newfakehostip" 0 "Checking to ensure that dig returns the correct ip address"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-replicaprepare-04 check reverse entry of the replica was created in dns correctly with dig"
		sleep 75
		rlLog "EXECUTING: dig -x $newfakehostip | grep newfakehost$newip.$DOMAIN"
		rlRun "dig -x $newfakehostip | grep newfakehost$newip.$DOMAIN" 0 "Checking to ensure that reverse of newfakehost$newip.$DOMAIN is set up correctly"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-replicaprepare-05 check forward ip of replica is resolvable by dnsrecord-show"
		rlLog "EXECUTING: ipa dnsrecord-show $DOMAIN newfakehost$newip"
		rlRun "ipa dnsrecord-show $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dnsrecord-show seems to think that the entry exists"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-replicaprepare-06 check reverse ip of the replica is resolvable by dnsrecord-show"
		rlRun "ipa dnsrecord-show $DOMAIN newfakehost$newip" 0 "Checking to ensure that ipa dnsrecord-show gives the reverse for fakehost"
		rlRun "ipa dnsrecord-del $DOMAIN newfakehost$newip --del-all" 0 "Delete the record created for the fake replica"
	rlPhaseEnd
}

dnszone()
{
	rlPhaseStartTest "ipa-dns-zone-01 create a new zone"
		rlLog "Executing: ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone" 0 "Checking to ensure that ipa thinks that it can create a zone"
		#rlRun "/usr/sbin/ipactl restart" 0 "Restarting IPA server"
	rlPhaseEnd

# Neg zone add test cases
	rlPhaseStartTest "ipa-dns-zone-02 try to create a new zone using a bad serial number"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$badnum --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-03 try to create a new zone using a bad refresh"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$badnum --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad refresh"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-04 try to create a new zone using a bad retry"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$badnum --expire=$expire --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-05 try to create a new zone using a bad expire"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$badnum --minimum=$minimum --ttl=$ttl zone" 1 "trying to create a zone using a bad expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-06 try to create a new zone using a bad minimum"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$badnum --ttl=$ttl zone" 1 "trying to create a zone using a bad minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-07 try to create a new zone using a bad ttl"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$badnum zone" 1 "trying to create a zone using a bad ttl"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-08 checking to ensure that the new zone got created with the correct name-server"
		rlRun "ipa dnszone-find --all $zone | grep $ipaddr" 0 "checking to ensure that the new zone got created with the correct name-server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-09 checking to ensure that the new zone got created with the correct email"
		rlRun "ipa dnszone-find --all $zone | grep $email" 0 "checking to ensure that the new zone got created with the correct email"
	rlPhaseEnd

        # with changes for SOA Serial Autoincrement, this test is not valid anymore
#	rlPhaseStartTest "ipa-dns-zone-10 checking to ensure that the new zone got created with the correct serial number"
#		rlRun "ipa dnszone-find --all $zone | grep $serial" 0 "checking to ensure that the new zone got created with the correct serial number"
#	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-11 checking to ensure that the new zone got created with the correct refresh"
		rlRun "ipa dnszone-find --all $zone | grep $refresh" 0 "checking to ensure that the new zone got created with the correct "
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-12 checking to ensure that the new zone got created with the correct retry"
		rlRun "ipa dnszone-find --all $zone | grep $retry" 0 "checking to ensure that the new zone got created with the correct retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-13 checking to ensure that the new zone got created with the correct expire"
		rlRun "ipa dnszone-find --all $zone | grep $expire" 0 "checking to ensure that the new zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-14 checking to ensure that the new zone got created with the correct minimum"
		rlRun "ipa dnszone-find --all $zone | grep $minimum" 0 "checking to ensure that the new zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-15 checking to ensure that the new zone got created with the correct ttl"
		rlRun "ipa dnszone-find --all $zone | grep $ttl" 0 "checking to ensure that the new zone got created with the correct ttl"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-16 checking to with dig to ensure that the new zone got created with the correct name server"
		rlRun "dig $zone SOA | grep NS | grep $ipaddr" 0 "checking with dig to ensure that the new zone got created with the correct name server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-17 checking to with dig to ensure that the new zone got created with the correct email"
		rlRun "dig $zone SOA | grep $email" 0 "checking with dig to ensure that the new zone got created with the correct email"
	rlPhaseEnd

        # with changes for SOA Serial Autoincrement, this test is not valid anymore
#	rlPhaseStartTest "ipa-dns-zone-18 checking to with dig to ensure that the new zone got created with the correct serial number"
#		rlRun "dig $zone SOA | grep $serial" 0 "checking with dig to ensure that the new zone got created with the correct serial number"
#	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-19 checking to with dig to ensure that the new zone got created with the correct refresh"
		rlRun "dig $zone SOA | grep $refresh" 0 "checking with dig to ensure that the new zone got created with the correct refresh"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-20 checking to with dig to ensure that the new zone got created with the correct retry interval"
		rlRun "dig $zone SOA | grep $retry" 0 "checking with dig to ensure that the new zone got created with the correct retry interval"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-21 checking to with dig to ensure that the new zone got created with the correct expire"
		rlRun "dig $zone SOA | grep $expire" 0 "checking with dig to ensure that the new zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-22 checking to with dig to ensure that the new zone got created with the correct minimum"
		rlRun "dig $zone SOA | grep $minimum" 0 "checking with dig to ensure that the new zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-zone-23 checking to with dig to ensure that the new zone got created with the correct ttl"
		rlRun "dig $zone SOA | grep $ttl" 0 "checking with dig to ensure that the new zone got created with the correct ttl"
	rlPhaseEnd
}

dnsarecord()
{
	rlPhaseStartTest "ipa-dns-arecord-01 add record of type A"
		rlRun "ipa dnsrecord-add $zone allll --a-rec $a" 0 "add record type a"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-02 make sure that IPA saved record type A"
		rlRun "ipa dnsrecord-find $zone allll | grep $a" 0 "make sure ipa recieved record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-03 make sure that dig can find the record type A"
		rlRun "dig allll.$zone | grep $a" 0 "make sure dig can find the A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-04 delete record of type A"
		rlRun "ipa dnsrecord-del $zone allll --a-rec $a" 0 "delete record type a"
		rlRun "ipa dnsrecord-find $zone allll" 1 "make sure ipa deleted record type A"
		rlRun "dig allll.$zone A | grep $a" 1 "make sure dig can not find the A record"
	rlPhaseEnd

	# Type Multiple A's
	rlPhaseStartTest "ipa-dns-arecord-05 add record of type multiple A records"
		rlRun "ipa dnsrecord-add $zone aa2 --a-rec $multiarecord1 --a-rec $multiarecord2" 0 "add record type a"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-06 make sure that IPA saved the first type A record"
		rlRun "ipa dnsrecord-find $zone aa2 | grep \"$multiarecord1\"" 0 "make sure ipa recieved record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-07 make sure that dig can find the first a record"
		rlRun "dig aa2.$zone | grep \"$multiarecord1\"" 0 "make sure dig finds the first A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-08 make sure that IPA saved the second type A record"
		rlRun "ipa dnsrecord-find $zone aa2 | grep \"$multiarecord2\"" 0 "make sure ipa recieved second record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-09 make sure that dig can find the second a record"
		rlRun "dig aa2.$zone | grep \"$multiarecord2\"" 0 "make sure dig finds the first A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-10 delete record of type multiple A"
		rlRun "ipa dnsrecord-del $zone aa2 --a-rec $multiarecord1 --a-rec $multiarecord2" 0 "delete record type multiple a"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-11 make sure that IPA removed the first type A record"
		rlRun "ipa dnsrecord-find $zone aa2 | grep $multiarecord1" 1 "make sure ipa removed record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-12 make sure that dig cannot find the first a record"
		rlRun "dig aa2.$zone | grep $multiarecord1" 1 "make sure dig does not find the first A record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-13 make sure that IPA removed the second type A record"
		rlRun "ipa dnsrecord-find $zone aa2 | grep $multiarecord2" 1 "make sure ipa removed second record type A"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-arecord-14 make sure that dig can not find the second a record"
		rlRun "dig aa2.$zone | grep $multiarecord2" 1 "make sure dig does not finds the first A record"
	rlPhaseEnd
}

dnsaaaarecord()
{
	# Type AAAA
	rlPhaseStartTest "ipa-dns-aaaarecord-01 add record of type AAAA"
		rlRun "ipa dnsrecord-add $zone aaaa --aaaa-rec='$aaaa'" 0 "add record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-aaaarecord-02 make sure that IPA saved record type AAAA"
		rlRun "ipa dnsrecord-find $zone aaaa | grep $aaaa" 0 "make sure ipa recieved record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-aaaarecord-03 make sure that dig can find the record type AAAA"
		rlRun "dig aaaa.$zone AAAA | grep $aaaa" 0 "make sure dig can find the AAAA record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-aaaarecord-04 delete record of type AAAA"
		rlRun "ipa dnsrecord-del $zone aaaa --aaaa-rec $aaaa" 0 "delete record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-aaaarecord-05 make sure that IPA deleted record type AAAA"
		rlRun "ipa dnsrecord-find $zone aaaa" 1 "make sure ipa deleted record type AAAA"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-aaaarecord-06 make sure that dig can not find the record type AAAA"
		rlRun "dig aaaa.$zone AAAA | grep $aaaa" 1 "make sure dig can not find the AAAA record"
	rlPhaseEnd

        # Neg AAAA tests
        rlPhaseStartTest "ipa-dns-aaaarecord-07 add record of type bad AAAA"
                rlRun "ipa dnsrecord-add $zone aaaab --aaaa-rec $aaaabad1" 1 "add a bad record type AAAA"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-aaaarecord-08 make sure that IPA did not save record type AAAA"
                rlRun "ipa dnsrecord-find $zone aaaab | grep $aaaabad1" 1 "make sure ipa did not record type AAAA"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-aaaarecord-09 make sure that dig can not find the record type AAAA"
                rlRun "dig aaaab.$zone | grep $aaaabad1" 1 "make sure dig can not find the AAAA record"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-aaaarecord-10 add record of type bad AAAA"
                rlRun "ipa dnsrecord-add $zone aaaac --aaaa-rec $aaaabad2" 1 "add a bad record type AAAA"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-aaaarecord-11 make sure that IPA did not save record type AAAA"
                rlRun "ipa dnsrecord-find $zone aaaac | grep $aaaabad2" 1 "make sure ipa did not record type AAAA"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-aaaarecord-12 make sure that dig can not find the record type AAAA"
                rlRun "dig aaaac.$zone | grep $aaaabad2" 1 "make sure dig can not find the AAAA record"
        rlPhaseEnd

}

dnsafsbdrecord()
{
	# Type afsbd
	rlPhaseStartTest "ipa-dns-iafsbdrecord-01 add record of type afsdb"
		rlRun "ipa dnsrecord-add $zone afsdb --afsdb-rec='0 $afsdb'" 0 "add record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-iafsbdrecord-02 make sure that IPA saved record type afsdb"
		rlRun "ipa dnsrecord-find $zone afsdb | grep $afsdb" 0 "make sure ipa recieved record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-iafsbdrecord-03 make sure that dig can find the record type afsdb"
		rlRun "dig afsdb.$zone AFSDB | grep $afsdb" 0 "make sure dig can find the afsdb record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-iafsbdrecord-04 delete record of type afsdb"
		rlRun "ipa dnsrecord-del $zone afsdb --afsdb-rec='0 $afsdb'" 0 "delete record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-iafsbdrecord-05 make sure that IPA deleted record type afsdb"
		rlRun "ipa dnsrecord-find $zone afsdb" 1 "make sure ipa deleted record type afsdb"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-iafsbdrecord-06 make sure that dig can not find the record type afsdb"
		rlRun "dig afsdb.$zone AFSDB | grep $afsdb" 1 "make sure dig can not find the afsdb record"
	rlPhaseEnd

}

dnscnamerecord()
{
	# Type cname
	rlPhaseStartTest "ipa-dns-cnamerecord-01 add record of type cname"
		rlRun "ipa dnsrecord-add $zone cname --cname-rec $cname" 0 "add record type cname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-cnamerecord-02 make sure that IPA saved record type cname"
		rlRun "ipa dnsrecord-find $zone cname | grep $cname" 0 "make sure ipa recieved record type cname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-cnamerecord-03 make sure that dig can find the record type cname"
		rlRun "dig cname.$zone CNAME | grep $cname" 0 "make sure dig can find the cname record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-cnamerecord-04 delete record of type cname"
		rlRun "ipa dnsrecord-del $zone cname --cname-rec $cname" 0 "delete record type cname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-cnamerecord-05 make sure that IPA deleted record type cname"
		rlRun "ipa dnsrecord-find $zone cname" 1 "make sure ipa deleted record type cname"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-cnamerecord-06 make sure that dig can not find the record type cname"
		rlRun "dig cname.$zone CNAME | grep $cname" 1 "make sure dig can not find the cname record"
	rlPhaseEnd
}

dnstxtrecord()
{
	# TXT Record
	rlPhaseStartTest "ipa-dns-txtrecord-01 add record of type txt"
		rlRun "ipa dnsrecord-add $zone txt --txt-rec $txt" 0 "add record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-txtrecord-02 make sure that IPA saved record type txt"
		rlRun "ipa dnsrecord-find $zone txt | grep $txt" 0 "make sure ipa recieved record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-txtrecord-03 make sure that dig can find the record type txt"
		rlRun "dig txt.$zone TXT | grep $txt" 0 "make sure dig can find the txt record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-txtrecord-04 delete record of type txt"
		rlRun "ipa dnsrecord-del $zone txt --txt-rec $txt" 0 "delete record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-txtrecord-05 make sure that IPA deleted record type txd"
		rlRun "ipa dnsrecord-find $zone txt" 1 "make sure ipa deleted record type txt"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-txtrecord-06 make sure that dig can not find the record type txt"
		rlRun "dig txt.$zone TXT | grep $txt" 1 "make sure dig can not find the txt record"
	rlPhaseEnd
}

dnssvrrecord()
{
	# SRV Record
	rlPhaseStartTest "ipa-dns-svrrecord-01 add record of type srv"
		rlRun "ipa dnsrecord-add $zone _srv --srv-rec '$srva $srv'" 0 "add record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-svrrecord-02 make sure that IPA saved record type srv"
		rlRun "ipa dnsrecord-find $zone _srv | grep $srv" 0 "make sure ipa recieved record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-svrrecord-03 make sure that dig can find the record type srv"
		rlRun "dig _srv.$zone SRV | grep $srv" 0 "make sure dig can find the srv record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-svrrecord-04 delete record of type srv"
		rlRun "ipa dnsrecord-del --del-all $zone _srv" 0 "delete record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-svrrecord-05 make sure that IPA deleted record type srv"
		rlRun "ipa dnsrecord-find $zone _srv" 1 "make sure ipa deleted record type srv"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-svrrecord-06 make sure that dig can not find the record type srv"
		rlRun "dig _srv.$zone SRV | grep $srv" 1 "make sure dig can not find the srv record"
	rlPhaseEnd
}

dnsmxrecord()
{
	# MX record 
	rlPhaseStartTest "ipa-dns-mxrecord-01 add record of type MX"
		rlRun "ipa dnsrecord-add $zone @ --mx-rec '10 $mx.'" 0 "add record type MX"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-mxrecord-02 make sure that IPA saved record type MX"
		rlRun "ipa dnsrecord-find $zone | grep $mx" 0 "make sure ipa recieved record type MX"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-mxrecord-03 make sure that dig can find the record type MX"
		rlRun "dig $zone MX | grep $mx" 0 "make sure dig can find the MX record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-mxrecord-04 delete record of type MX"
		rlRun "ipa dnsrecord-del $zone @ --mx-rec '10 $mx.'" 0 "delete record type MX"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-mxrecord-05 make sure that IPA deleted record type MX"
		rlRun "ipa dnsrecord-find $zone @ | grep $mx" 1 "make sure ipa deleted record type MX"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-mxrecord-06 make sure that dig can not find the record type MX"
		rlRun "dig $zone MX | grep $mx" 1 "make sure dig can not find the MX record"
	rlPhaseEnd
}

dnsptrzone()
{

# Neg PTR zone add test cases
	rlPhaseStartTest "ipa-dns-ptrzone-01 try to create a new ptr zone using a bad serial number"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$pemail --serial=$pbadnum --refresh=$prefresh --retry=$pretry --expire=$pexpire --minimum=$pminimum --ttl=$pttl $bptrzone" 1 "trying to create a zone using a bad serial number"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-02 try to create a new zone using a bad refresh"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$pemail --serial=$pserial --refresh=$pbadnum --retry=$pretry --expire=$pexpire --minimum=$pminimum --ttl=$pttl $bptrzone" 1 "trying to create a zone using a bad refresh"
	rlPhaseEnd
# End Neg test cases

# Create a PTR zone
	rlPhaseStartTest "ipa-dns-ptrzone-03 try to create a new PTR zone"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$pemail --serial=$pserial --refresh=$prefresh --retry=$pretry --expire=$pexpire --minimum=$pminimum --ttl=$pttl $ptrzone" 0 "Creating a new PTR zone for use in following tests"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-04 checking to ensure that the new PTR zone got created with the correct name-server"
		rlRun "ipa dnszone-find --all $ptrzone | grep $ipaddr" 0 "checking to ensure that the new PTR zone got created with the correct name-server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-05 checking to ensure that the new PTR zone got created with the correct email"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pemail" 0 "checking to ensure that the new PTR zone got created with the correct email"
	rlPhaseEnd

        # with changes for SOA Serial Autoincrement, this test is not valid anymore
#	rlPhaseStartTest "ipa-dns-ptrzone-06 checking to ensure that the new PTR zone got created with the correct serial number"
#		rlRun "ipa dnszone-find --all $ptrzone | grep $pserial" 0 "checking to ensure that the new PTR zone got created with the correct serial number"
#	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-07 checking to ensure that the new PTR zone got created with the correct refresh"
		rlRun "ipa dnszone-find --all $ptrzone | grep $prefresh" 0 "checking to ensure that the new PTR zone got created with the correct "
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-08 checking to ensure that the new PTR zone got created with the correct retry"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pretry" 0 "checking to ensure that the new PTR zone got created with the correct retry"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-09 checking to ensure that the new PTR zone got created with the correct expire"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pexpire" 0 "checking to ensure that the new PTR zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-10 checking to ensure that the new PTR zone got created with the correct minimum"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pminimum" 0 "checking to ensure that the new PTR zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-11 checking to ensure that the new PTR zone got created with the correct ttl"
		rlRun "ipa dnszone-find --all $ptrzone | grep $pttl" 0 "checking to ensure that the new PTR zone got created with the correct ttl"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-12 checking to with dig to ensure that the new PTR zone got created with the correct name server"
		rlRun "dig $ptrzone SOA | grep NS | grep $ipaddr" 0 "checking with dig to ensure that the new PTR zone got created with the correct name server"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-13 checking to with dig to ensure that the new PTR zone got created with the correct email"
		rlRun "dig $ptrzone SOA | grep $pemail" 0 "checking with dig to ensure that the new PTR zone got created with the correct email"
	rlPhaseEnd

        # with changes for SOA Serial Autoincrement, this test is not valid anymore
#	rlPhaseStartTest "ipa-dns-ptrzone-14 checking to with dig to ensure that the new PTR zone got created with the correct serial number"
#		rlRun "dig $ptrzone SOA | grep $pserial" 0 "checking with dig to ensure that the new PTR zone got created with the correct serial number"
#	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-15 checking to with dig to ensure that the new PTR zone got created with the correct refresh"
		rlRun "dig $ptrzone SOA | grep $prefresh" 0 "checking with dig to ensure that the new PTR zone got created with the correct refresh"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-16 checking to with dig to ensure that the new PTR zone got created with the correct retry interval"
		rlRun "dig $ptrzone SOA | grep $pretry" 0 "checking with dig to ensure that the new PTR zone got created with the correct retry interval"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-17 checking to with dig to ensure that the new PTR zone got created with the correct expire"
		rlRun "dig $ptrzone SOA | grep $pexpire" 0 "checking with dig to ensure that the new PTR zone got created with the correct expire"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-18 checking to with dig to ensure that the new PTR zone got created with the correct minimum"
		rlRun "dig $ptrzone SOA | grep $pminimum" 0 "checking with dig to ensure that the new PTR zone got created with the correct minimum"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrzone-19 checking to with dig to ensure that the new PTR zone got created with the correct ttl"
		rlRun "dig $ptrzone SOA | grep $pttl" 0 "checking with dig to ensure that the new PTR zone got created with the correct ttl"
	rlPhaseEnd
}

dnsptrrecord()
{
	# PTR record 
	rlPhaseStartTest "ipa-dns-ptrrecord-01 add record of type PTR"
		rlRun "ipa dnsrecord-add $ptrzone $ptr --ptr-rec=$ptrvalue" 0 "add record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrrecord-02 make sure that IPA saved record type PTR"
		rlRun "ipa dnsrecord-find $ptrzone $ptr | grep $ptrvalue" 0 "make sure ipa recieved record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrrecord-03 make sure that dig can find the record type PTR"
		rlRun "dig -x $ptroctet.$ptr PTR | grep $ptrvalue" 0 "make sure dig can find the PTR record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrrecord-04 delete record of type PTR"
		rlRun "ipa dnsrecord-del $ptrzone $ptr --ptr-rec $ptrvalue" 0 "delete record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrrecord-05 make sure that IPA deleted record type PTR"
		rlRun "ipa dnsrecord-find $ptrzone $ptr | grep $ptrvalue" 1 "make sure ipa deleted record type PTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-ptrrecord-06 make sure that dig can not find the record type PTR"
		rlRun "dig -x $ptroctet.$ptr PTR | grep $ptrvalue" 1 "make sure dig can not find the PTR record"
	rlPhaseEnd
}

dnsnaptrrecord()
{
	# Type NAPTR
	rlPhaseStartTest "ipa-dns-naptrrecord-01 add record of type NAPTR"
		echo "running ipa dnsrecord-add $zone naptr --naptr-rec '$naptr'"
		rlRun "ipa dnsrecord-add $zone naptr --naptr-rec '$naptr'" 0 "add record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-naptrrecord-02 make sure that IPA saved record type NAPTR"
		rlRun "ipa dnsrecord-find $zone naptr | grep '$naptr'" 0 "make sure ipa recieved record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-naptrrecord-03 make sure that dig can find the record type NAPTR"
		rlRun "dig naptr.$zone NAPTR | grep '$naptrfind'" 0 "make sure dig can find the NAPTR record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-naptrrecord-04 delete record of type NAPTR"
		rlRun "ipa dnsrecord-del $zone naptr --naptr-rec '$naptr'" 0 "delete record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-naptrrecord-05 make sure that IPA deleted record type NAPTR"
		rlRun "ipa dnsrecord-find $zone naptr" 1 "make sure ipa deleted record type NAPTR"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-naptrrecord-06 make sure that dig can not find the record type NAPTR"
		rlRun "dig naptr.$zone NAPTR | grep '$naptrfind'" 1 "make sure dig can not find the NAPTR record"
	rlPhaseEnd
}

dnsdnamerecord()
{
	# Type dname
	rlPhaseStartTest "ipa-dns-dnamerecord-01 add record of type dname"
		rlRun "ipa dnsrecord-add $zone dname --dname-rec $dname" 0 "add record type dname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-dnamerecord-02 make sure that IPA saved record type dname"
		rlRun "ipa dnsrecord-find $zone dname | grep $dname" 0 "make sure ipa recieved record type dname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-dnamerecord-03 make sure that dig can find the record type dname"
		rlRun "dig dname.$zone DNAME | grep $dname" 0 "make sure dig can find the dname record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-dnamerecord-04 delete record of type dname"
		rlRun "ipa dnsrecord-del $zone dname --dname-rec $dname" 0 "delete record type dname"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-dnamerecord-05 make sure that IPA deleted record type dname"
		rlRun "ipa dnsrecord-find $zone dname" 1 "make sure ipa deleted record type dname"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-dnamerecord-06 make sure that dig can not find the record type dname"
		rlRun "dig dname.$zone DNAME | grep $dname" 1 "make sure dig can not find the dname record"
	rlPhaseEnd
}

dnscertrecord()
{
	# Type cert
	rlPhaseStartTest "ipa-dns-certrecord-01 add record of type cert"
		rlRun "ipa dnsrecord-add $zone cert --cert-rec=\"$certb $cert\"" 0 "add record type cert"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-certrecord-02 make sure that IPA saved record type cert"
		rlRun "ipa dnsrecord-find $zone cert | grep $cert" 0 "make sure ipa recieved record type cert"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-certrecord-03 make sure that dig can find the record type cert"
		rlRun "dig cert.$zone CERT | grep $cert" 0 "make sure dig can find the cert record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-certrecord-04 delete record of type cert"
		rlRun "ipa dnsrecord-del $zone cert --cert-rec=\"$certb $cert\"" 0 "delete record type cert"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-certrecord-05 make sure that IPA deleted record type cert"
		rlRun "ipa dnsrecord-find $zone cert" 1 "make sure ipa deleted record type cert"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-certrecord-06 make sure that dig can not find the record type cert"
		rlRun "dig cert.$zone CERT | grep $cert" 1 "make sure dig can not find the cert record"
	rlPhaseEnd
}

dnslocrecord()
{
	# Type loc
	rlPhaseStartTest "ipa-dns-locrecord-01 add record of type loc"
		rlRun "ipa dnsrecord-add $zone @ --loc-rec '$loc'" 0 "add record type loc"
	rlPhaseEnd

#	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-locrecord-02 make sure that IPA saved record type loc"
		rlRun "ipa dnsrecord-find $zone | grep '$loclong'" 0 "make sure ipa recieved record type loc"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-locrecord-03 make sure that dig can find the record type loc"
		file="/opt/rhqa_ipa/dig-loc-result.txt"
		dig $zone LOC > $file
		cat $file
		rlRun "grep '$loclong' $file" 0 "make sure dig can find the loc record looking for long"
		rlRun "grep '$loclat' $file" 0 "make sure dig can find the loc record looking for lat"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-locrecord-04 delete record of type loc"
		rlRun "ipa dnsrecord-del $zone @ --loc-rec '$loc'" 0 "delete record type loc"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-locrecord-05 make sure that IPA deleted record type loc"
		rlRun "ipa dnsrecord-find $zone loc" 1 "make sure ipa deleted record type loc"
	rlPhaseEnd

	sleep 5
	rlPhaseStartTest "ipa-dns-locrecord-06 make sure that dig can not find the record type loc"
		rlRun "dig $zone loc | grep $loclong" 1 "make sure dig can not find the loc record"
	rlPhaseEnd
}

dnskxrecord()
{
	# Type kx
	rlPhaseStartTest "ipa-dns-kxrecord-01 add record of type kx"
		rlRun "ipa dnsrecord-add $zone @ --kx-rec \"$kxpref1 $ahost\"" 0 "add record type kx"
	rlPhaseEnd

#	/etc/init.d/named restart

	rlPhaseStartTest "ipa-dns-kxrecord-02 make sure that IPA saved record type kx"
		rlRun "ipa dnsrecord-show $zone @ | grep $kxpref1" 0 "make sure ipa recieved record type kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-kxrecord-03 make sure that dig can find the record type kx"
		rlRun "dig $zone kx | grep $kxpref1" 0 "make sure dig can find the kx record"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-kxrecord-04 delete record of type kx"
		rlRun "ipa dnsrecord-del $zone @ --kx-rec \"$kxpref1 $ahost\"" 0 "delete record type kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-kxrecord-05 make sure that IPA deleted record type kx"
		rlRun "ipa dnsrecord-find $zone kx" 1 "make sure ipa deleted record type kx"
	rlPhaseEnd

	sleepd
	rlPhaseStartTest "ipa-dns-kxrecord-06 make sure that dig can not find the record type kx"
		rlRun "dig $zone kx | grep $kxpref1" 1 "make sure dig can not find the kx record"
	rlPhaseEnd

	# Negitive kx tests

	rlPhaseStartTest "ipa-dns-kxrecord-07 add record of type bad kx"
		rlRun "ipa dnsrecord-add $zone @ --kx-rec '$kxbadpref1 $a'" 1 "add record type bad kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-kxrecord-08 make sure that IPA saved record type kx"
		rlRun "ipa dnsrecord-find $zone @ | grep \"\\$kxbadpref1\"" 1 "make sure ipa recieved record type kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-kxrecord-09 add record of type bad kx"
		rlRun "ipa dnsrecord-add $zone @ --kx-rec '$kxbadpref2 $zone'" 1 "add record type bad kx"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-kxrecord-10 make sure that IPA saved record type kx"
		rlRun "ipa dnsrecord-find $zone @ | grep $kxbadpref2" 1 "make sure ipa recieved record type kx"
	rlPhaseEnd
}

dnszonepermission()
{
   # Positive add permission
       rlPhaseStartTest "ipa-dnszone-permission-01 add zone, then a permission to manage it, and verify if managedby attribute is set, and that permission is added"
          ipa dnszone-add --name-server=$ipaddr --admin-email=$email $managedZone
          rlRun "ipa dnszone-add-permission $managedZone" 0 "Add permission to manage zone"
          rlRun "ipa dnszone-show $managedZone --all | grep -i managedby" 0 "Verify managedby attribute is set"
          rlRun "ipa permission-find \"manage dns zone $managedZone\"" 0 "Verify permission is added to manage the zone"
       rlPhaseEnd
       
   # Positive remove permission
       rlPhaseStartTest "ipa-dnszone-permission-02 Remove permission to manage zone, verify managedby attribute is not set, and permission is deleted"
          rlRun "ipa dnszone-remove-permission $managedZone" 0 "Remove permission for zone to be managed"
          rlRun "ipa dnszone-show $managedZone --all | grep -i managedby" 1 "Verify managedby attribute is not available" 
          rlRun "ipa permission-find \"manage dns zone $managedZone\"" 1 "Verify permission to manage the zone is removed" 
       rlPhaseEnd

       rlPhaseStartTest "ipa-dnszone-permission-03 add zone, then a permission to manage it, then delete the zone and verify that permission is deleted"
          rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email $managedZone1" 0 "Add zone to be managed"
          rlRun "ipa dnszone-add-permission $managedZone1" 0 "Add permission to manage zone"
          rlRun "ipa dnszone-del $managedZone1" 0 "Delete the zone"
          rlRun "ipa permission-find \"manage dns zone $managedZone1\"" 1 "Verify permission is removed when zone is deleted"
       rlPhaseEnd

   # Negative add permission
       rlPhaseStartTest "ipa-dnszone-permission-04 add duplicate permission to manage zone" 
          ipa dnszone-add-permission $managedZone
          command="ipa dnszone-add-permission $managedZone" 
          expMsg="ipa: ERROR: permission with name \"Manage DNS zone $managedZone\" already exists"
          rlRun "$command > $TmpDir/dnszonepermission_duplicate.log 2>&1" 1 "Verify error message when adding duplicate permission for zone"
          rlAssertGrep "$expMsg" "$TmpDir/dnszonepermission_duplicate.log"
       rlPhaseEnd

       rlPhaseStartTest "ipa-dnszone-permission-05 add permission to manage non-existent zone" 
          command="ipa dnszone-add-permission $nonexistentZone" 
          expMsg="ipa: ERROR: $nonexistentZone: DNS zone not found"
          rlRun "$command > $TmpDir/dnszonepermission_addfornonexistentzone.log 2>&1" 2 "Verify error message when adding permission for non existent zone"
          rlAssertGrep "$expMsg" "$TmpDir/dnszonepermission_addfornonexistentzone.log"
       rlPhaseEnd

   # Negative remove permission
       rlPhaseStartTest "ipa-dnszone-permission-06 Remove permission to manage zone again"
          ipa dnszone-remove-permission $managedZone
          command="ipa dnszone-remove-permission $managedZone"
          expMsg="ipa: ERROR: Manage DNS zone $managedZone: permission not found"
          rlRun "$command > $TmpDir/dnszonepermission_redelete.log 2>&1" 2 "Verify error message for when deleting permission for zone again"
          rlAssertGrep "$expMsg" "$TmpDir/dnszonepermission_redelete.log"
       rlPhaseEnd

       rlPhaseStartTest "ipa-dnszone-permission-07 Remove permission for non-existent zone" 
          command="ipa dnszone-remove-permission $nonexistentZone"
          expMsg="ipa: ERROR: $nonexistentZone: DNS zone not found"
          rlRun "$command > $TmpDir/dnszonepermission_deletefornonexistentzone.log 2>&1" 2 "Verify error message for when deleting permission for non existent zone"
          rlAssertGrep "$expMsg" "$TmpDir/dnszonepermission_deletefornonexistentzone.log"
       rlPhaseEnd

  # cleanup
     ipa dnszone-del $managedZone
}

dnspsearch()
{
# ref: https://fedoraproject.org/wiki/QA:Testcase_freeipav3_dns_persistent_search

	rlPhaseStartTest "ipa-dns-psearch-01 psearch is enabled when ipa server is installed" 
	      rlAssertGrep "psearch yes" "/etc/named.conf"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-psearch-02 create a new zone and check the zone with dig"
		rlLog "Executing: ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zonepsearch"
		rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zonepsearch" 0 "Create a new zone"
		rlLog "Executing: dig $zonepsearch SOA | grep NS | grep $ipaddr"
		rlRun "dig $zonepsearch SOA | grep NS | grep $ipaddr" 0 "checking with dig to ensure that the new zone got created with the correct name server"
	rlPhaseEnd

        rlPhaseStartTest "ipa-dns-psearch-03 add record of type txt and check the record with dig"
                rlLog "Executing: ipa dnsrecord-add $zonepsearch txt --txt-rec $txt"
                rlRun "ipa dnsrecord-add $zonepsearch txt --txt-rec $txt" 0 "add record type txt"
		rlLog "Executing: dig txt.$zonepsearch TXT | grep $txt"
		rlRun "dig txt.$zonepsearch TXT | grep $txt" 0 "make sure dig can find the txt record"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-psearch-04 update record's txt value and check using dig"
                rlLog "Executing: ipa dnsrecord-mod $zonepsearch txt --txt-rec=$txt --txt-data=$newtxt"
                rlRun "ipa dnsrecord-mod $zonepsearch txt --txt-rec=$txt --txt-data=$newtxt" 0 "modify record type txt"
		rlLog "Executing: dig txt.$zonepsearch TXT | grep $newtxt"
		rlRun "dig txt.$zonepsearch TXT | grep $newtxt" 0 "make sure dig can find updated txt record"
        rlPhaseEnd

        rlPhaseStartTest "ipa-dns-psearch-05 update record's txt value again and check zone has a new serial that is higher than previous serial"
		oldserial=`dig $zonepsearch +multiline -t SOA | grep serial | cut -d ";" -f1 | xargs echo`
                rlLog "Executing: ipa dnsrecord-mod $zonepsearch txt --txt-rec=$newtxt --txt-data=$newertxt"
                rlRun "ipa dnsrecord-mod $zonepsearch txt --txt-rec=$newtxt --txt-data=$newertxt" 0 "update record type txt"
		newserial=`dig $zonepsearch +multiline -t SOA | grep serial | cut -d ";" -f1 | xargs echo`
                if [ $oldserial -gt $newserial ]; then
                        rlFail "new serial after updating record is not higher. Was: $oldserial; New: $newserial"
                else
                        rlPass "new serial after updating record is higher. Was: $oldserial; New: $newserial"
                fi
        rlPhaseEnd

# Revisit test - failing in beaker
#        rlPhaseStartTest "bz829387 - psearch code hardening"
#           rlRun "tail -n40 /var/log/messages | grep -i \"(psearch) failed\"" 1 "Checking /var/log/messages for:  (psearch) failed"
#         rlPhaseEnd


#  cleanup
       rlLog "Executing: ipa dnszone-del $zonepsearch"
       ipa dnszone-del $zonepsearch

# test not for here: check upgrade
# tasks 162, 606, 778, 784, 939, 783
}

dnscleanup()
{
	rlPhaseStartTest "dns acceptance cleanup"
		rlRun "ipa dnszone-del $zone" 0 "Delete the zone created for this test"
		rlRun "ipa dnszone-find $zone" 1 "Make sure the zone delete happened properly"
		rlRun "ipa dnszone-del $ptrzone" 0 "Delete the ptr zone created for this test"
		rlRun "ipa dnszone-find $ptrzone" 1 "Make sure the ptr zone delete happened properly"
	rlPhaseEnd
}
