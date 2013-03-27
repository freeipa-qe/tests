
#########################################
# Variables
#########################################
zone=newzone
email="ipaqar.redhat.com"

##########################################
#   Test Suite 
#########################################

dnsbugs()
{
   dnsbugsetup
   bz814495
   bz841900
   bz750947
   bz789987
   bz789919
   bz790318
   bz738788
   bz766075
   bz751776
   bz797561
   bz783272
   bz750806
   bz733371
   bz767492
   bz767494
   bz804619
   bz804562
   bz795414
   bz805427
   bz805871
   bz804572
   bz772301
   bz818933
   bz805430
   bz819635
   bz809562
   bz828687
   bz817413
   bz813380
   bz829340
   bz798493
   bz809565
   bz829728
   bz829388
   bz829353
   bz840383

# Revisit commented tests below - since they are failing in beaker. 
# Trac tasks for these have been moved to backlog
#   bz701677
#   bz802375
#   bz767489
   # Note: this test possibly creates an env that is not good for further tests. Not recovering correctly
    bz767496

   #   bz798355 Test moved to install-client-cli test
   dnsbugcleanup
}

###############################################################
# Tests
###############################################################

dnsbugsetup()
{
    rlPhaseStartTest "dns bug setup"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	# add test zone
	rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$email $zone" 0 "Add test zone: $zone"
	# Determine my IP address
    rlPhaseEnd
}

bz814495()
{

        # Tests for bug https://bugzilla.redhat.com/show_bug.cgi?id=814495
        rlPhaseStartTest "bz814495 IPA DNS locks up and burns horribly after trying to resolve an incorrect query"

	        rlRun "ipactl restart"
	        sleep 15
	        rlRun "dig abc,xyz.$DOMAIN &"
	        sleep 10

        	rlRun "tail -n40 /var/log/messages | grep -i \"connection to the LDAP server was lost\"" 1
	        rlRun "tail -n40 /var/log/messages | grep -i \"LDAP error: Invalid DN syntax\"" 1

	        rlRun "tail -n40 /var/log/messages"

        	rlRun "ipactl restart"
	        sleep 15

	rlPhaseEnd

}

bz841900()
{
        # Tests for bug https://bugzilla.redhat.com/show_bug.cgi?id=841900
        rlPhaseStartTest "bz841900 EMBARGOED CVE-2012-3429 bind-dyndb-ldap: named DoS via DNS query with $ in name [rhel-6.3.z]"

                rlRun "dig @127.0.0.1 -t ANY '$.$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY '@.$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY '\".$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY '(.$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY ').$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY '..$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY ';.$DOMAIN' &"
                rlRun "dig @127.0.0.1 -t ANY '\.$DOMAIN' &"
                rlRun "tail -n40 /var/log/messages | grep -i \"ldap_convert.c:253: REQUIRE(dns_str_len > dns_idx + 3) failed, back trace\"" 1
                rlRun "tail -n40 /var/log/messages | grep \"/var/named/core\"" 1
                rlRun "tail -n40 /var/log/messages"

                rlRun "ipactl restart"
                sleep 15

    rlPhaseEnd
}


bz750947()
{
	# Tests for bug https://bugzilla.redhat.com/show_bug.cgi?id=750947
	rlPhaseStartTest "bz750947 Adding loc records to a ipa-dns server breaks name resolution for some other records"
		aaaa="fec0:0:a10:6000:11:16ff:fe98:122"
		rlRun "ipa dnsrecord-add $zone aaaa --aaaa-rec=\"$aaaa\""
		rlRun "ipa dnsrecord-find $zone aaaa | grep $aaaa" 0 "make sure ipa recieved record type AAAA"
		rlRun "dig aaaa.$zone AAAA | grep $aaaa" 0 "make sure dig can find the AAAA record"
		rlRun "ipa dnsrecord-del $zone aaaa --aaaa-rec=\"$aaaa\"" 0 "delete the AAAA record added"
	rlPhaseEnd

}

bz789987()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=789987
	rlPhaseStartTest "bz789987 Correction in error message while deleting a invalid record."
		verifyErrorMsg "ipa dnsrecord-del $zone aaaa --aaaa-rec=2620:52:0:41c9:5054:ff:fe62:65" "ipa: ERROR: aaaa: DNS resource record not found"
	rlPhaseEnd
}

bz789919()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=789919
	rlPhaseStartTest "bz789919 IP address with just 3 octets are accepted as valid addresses in --a-rec option"
		verifyErrorMsg "ipa dnsrecord-add $zone arec --a-rec=1.1.1" "ipa: ERROR: invalid 'ip_address': invalid IP address format"
	rlPhaseEnd
}

bz790318()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=790318
        rlPhaseStartTest "bz790318 dnsrecord-add does not validate the record names with space in between."
		rlRun "ipa dnsrecord-add $zone \"record name\"  --a-rec=1.1.1.1 | grep \"ipa: ERROR: invalid 'name': only letters, numbers, _, and - are allowed.\"" 1
        rlPhaseEnd
}

bz738788()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=738788
	rlPhaseStartTest "bz738788 ipa dnsrecord-add allows invalid kx records"
                rlRun "ipa dnsrecord-add $zone @ --kx-rec \"-1 1.2.3.4\" | grep \"ipa: ERROR: invalid 'preference': must be at least 0\"" 1
		rlRun "ipa dnsrecord-add $zone @ --kx-rec \"333383838383 1.2.3.4\" | grep \"ipa: ERROR: invalid 'preference': can be at most 65535\"" 1
	rlPhaseEnd
}

bz766075()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=766075
	rlPhaseStartTest "bz766075 DNS zone dynamic update is changed to false if --allow-dynupdate not specified"
		rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=admin@example.com --allow-dynupdate | grep \"ipa: error: no such option: --allow-dynupdate\"" 1

		rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=admin@example.com --dynamic-update"
		rlRun "ipa dnszone-show example.com | grep \"Dynamic update: TRUE\"" 1
		rlRun "ipa dnszone-show example.com --all | grep \"Dynamic update: TRUE\""
		rlRun "ipa dnszone-mod example.com --retry=600 | grep \"Dynamic update: FALSE\"" 1

		rlRun "ipa dnszone-show example.com --all | grep \"Dynamic update: FALSE\"" 1
		rlRun "ipa dnszone-show example.com --all | grep \"Dynamic update: TRUE\""

		rlRun "ipa dnszone-mod example.com --dynamic-update=false | grep \"Dynamic update: FALSE\""
		rlRun "ipa dnszone-mod example.com --retry=500"
		rlRun "ipa dnszone-show example.com --all | grep \"Dynamic update: FALSE\""

		rlRun "ipa dnszone-del example.com"

	rlPhaseEnd
}

bz751776()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=751776
	rlPhaseStartTest "bz751776 Skip invalid record in a zone instead of refusing to load entire zone"

		rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=admin@example.com"
		rlRun "ipa dnsrecord-add example.com foo --a-rec=10.0.0.1"
		sleep 5
		rlRun "dig +short -t A foo.example.com | grep 10.0.0.1"

		rlRun "ipa dnsrecord-add example.com @ --kx-rec=\"1 foo.example.com\""
		rlRun "ldapsearch -LLL -h localhost -Y GSSAPI -b idnsname=example.com,cn=dns,dc=testrelm,dc=com"

ldapmodify -h localhost -Y GSSAPI << EOF
dn: idnsname=example.com,cn=dns,dc=testrelm,dc=com
changetype: modify
replace: kXRecord
kXRecord: foo.example.com
EOF
		rlRun "ldapsearch -LLL -h localhost -Y GSSAPI -b idnsname=example.com,cn=dns,dc=testrelm,dc=com"

		sleep 5
		rlRun "dig +short -t A foo.example.com | grep 10.0.0.1"
		rlRun "dig +short -t A foo.example.com | grep 10.0.0.1"

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=751776"

		rlRun "ipa dnszone-del example.com"

	rlPhaseEnd
}

bz797561()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=797561
	rlPhaseStartTest "bz797561 Bool attributes used in setattr/addattr/delattr options are not encoded properly"
		rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=admin@example.com"
                rlRun "ipa dnszone-show example.com --all --raw | grep -i \"idnsallowdynupdate: FALSE\""
		
		verifyErrorMsg "ipa dnszone-mod example.com --addattr=idnsAllowDynUpdate=true" "ipa: ERROR: idnsallowdynupdate: Only one value allowed."
		rlRun "ipa dnszone-show example.com --all --raw | grep -i \"idnsallowdynupdate: FALSE\""

		rlRun "ipa dnszone-mod example.com --setattr=idnsAllowDynUpdate=true"
		rlRun "ipa dnszone-show example.com --all --raw | grep -i \"idnsallowdynupdate: TRUE\""

		rlRun "ipa dnszone-del example.com"

	rlPhaseEnd
}

bz783272()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=783272
	rlPhaseStartTest "bz783272 Confusing error message when adding a record to non-existent zone"
		rlRun "ipa dnsrecord-add unknowndomain.com recordname  --loc-rec=\"49 11 42.4 N 16 36 29.6 E 227.64m\" | grep \"ipa: ERROR: unknowndomain.com: DNS zone not found\"" 1
	rlPhaseEnd
}

bz750806()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=750806
        rlPhaseStartTest "bz750806 dnszone-mod and dnszone-add does not format administrator's email properly"
                rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=admin@example.com"
		rlRun "ipa dnszone-mod example.com --admin-email=foo.bar@example.com"
		rlRun "ipa dnszone-show example.com | grep \"Administrator e-mail address: foo\\\\\.bar.example.com.\""
		rlRun "ipa dnszone-del example.com"
	rlPhaseEnd
}

bz733371()
{
	rlPhaseStartTest "bz733371 DNS zones are not loaded when idnsAllowQuery/idnsAllowTransfer is filled"
		MASTERIP=`dig +short $MASTER`
		rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=admin@example.com"
                rlRun "ipa dnsrecord-add example.com foo --a-rec=10.0.1.1"
		rlRun "ipa dnszone-mod example.com --allow-query=$MASTERIP"
                rlRun "systemctl reload named"
		sleep 5
                rlRun "dig +short -t A foo.example.com | grep 10.0.1.1"
		rlRun "ipa dnszone-mod example.com --allow-query=10.0.1.1"
                rlRun "systemctl reload named"
                sleep 5
                rlRun "nslookup foo.example.com | grep \"server can't find foo.example.com\""
                rlRun "ipa dnszone-del example.com"
        rlPhaseEnd
}

bz767492()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=767492
        rlPhaseStartTest "bz767492 The plugin doesn't delete zone when it is deleted in LDAP and zone_refresh is set"
		rlRun "ipa dnszone-add unknownexample.com --name-server=$MASTER. --admin-email=admin@unknownexample.com"
		rlRun "ipa dnszone-mod unknownexample.com --refresh=30"
		rlRun "ipa dnsrecord-add unknownexample.com foo --a-rec=10.0.2.2"
		sleep 35
		rlRun "dig +short -t A foo.unknownexample.com | grep 10.0.2.2"
		rlRun "ipa dnszone-del unknownexample.com"
		rlRun "ipa dnszone-find unknownexample.com" 1
		sleep 35
		rlRun "dig +short -t A foo.unknownexample.com | grep 10.0.2.2" 1
	rlPhaseEnd
}

bz767494()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=767494
	rlPhaseStartTest "bz767494 Automatically update corresponding PTR record when A/AAAA record is updated"
		aaaa174="2620:52:0:2247:221:5eff:fe86:16b4"
		aaaa174rev="7.4.2.2.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa."
		a174="10.1.1.10"
		a174rev="1.1.10.in-addr.arpa."

		# for IPv4 +ve
		# rlRun "ipa dnszone-add $DOMAIN --name-server=$HOSTNAME --admin-email=$email" # $DOMAIN zone already exists, hence commenting.
		rlRun "ipa dnszone-add $a174rev --name-server=$MASTER. --admin-email=$email"

		rlRun "ipa dnsrecord-add $DOMAIN foo --a-rec=$a174 --a-create-reverse"
		rlRun "ipa dnsrecord-show $a174rev 10 | grep \"PTR record: foo.$DOMAIN\""
		sleep 5
		rlRun "dig -x $a174 | grep foo.$DOMAIN"

		# for IPv4 -ve
		verifyErrorMsg "ipa dnsrecord-add $DOMAIN foo --a-rec=$a174 --a-create-reverse" "ipa: ERROR: Reverse record for IP address $a174 already exists in reverse zone $a174rev."
		rlRun "ipa dnsrecord-add $DOMAIN foo2 --a-rec=10.1.2.10 --a-create-reverse | grep \"ipa: ERROR: Cannot create reverse record for \"10.1.2.10\": DNS reverse zone for IP address 10.1.2.10 not found\"" 1

		# record clean-up
		rlRun "ipa dnsrecord-del $a174rev 10 --del-all"

		# for IPv6 +ve
		rlRun "ipa dnszone-add $aaaa174rev --name-server=$MASTER. --admin-email=$email"
		rlRun "ipa dnsrecord-add $DOMAIN bar --aaaa-rec=$aaaa174 --aaaa-create-reverse"
		rlRun "ipa dnsrecord-show $aaaa174rev 4.b.6.1.6.8.e.f.f.f.e.5.1.2.2.0 | grep \"PTR record: bar.$DOMAIN\""
		sleep 5
		rlRun "dig -x $aaaa174 | grep bar.$DOMAIN"

		# for IPv6 -ve
		verifyErrorMsg "ipa dnsrecord-add $DOMAIN bar --aaaa-rec=$aaaa174 --aaaa-create-reverse" "ipa: ERROR: Reverse record for IP address $aaaa174 already exists in reverse zone $aaaa174rev."
		rlRun "ipa dnsrecord-add $DOMAIN bar --aaaa-rec=2621:52:0:2247:221:5eff:fe86:26b4 --aaaa-create-reverse | grep \"ipa: ERROR: Cannot create reverse record for \"2621:52:0:2247:221:5eff:fe86:26b4\": DNS reverse zone for IP address 2621:52:0:2247:221:5eff:fe86:26b4 not found\"" 1

		# record clean-up
		rlRun "ipa dnsrecord-del $aaaa174rev 4.b.6.1.6.8.e.f.f.f.e.5.1.2.2.0 --del-all"
		rlRun "ipa dnszone-del $a174rev" 0 "Deleting test zone $a174rev"
		rlRun "ipa dnszone-del $aaaa174rev" 0 "Deleting test zone $aaaa174rev"
                rlRun "ipa dnsrecord-del testrelm.com foo --del-all" 0 "Deleting record foo"
		rlRun "ipa dnsrecord-del testrelm.com foo2 --del-all" 0 "Deleting record foo2"
		rlRun "ipa dnsrecord-del testrelm.com bar --del-all" 0 "Deleting record bar"
	rlPhaseEnd
}

bz804619()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=804619
        rlPhaseStartTest "bz804619 DNS zone serial number is not updated"
		rlLog "Executing: ipa dnszone-show $DOMAIN --all --raw to get idnssoaserial"
		serial=`ipa dnszone-show $DOMAIN  --all --raw | grep -i idnssoaserial | cut -d :  -f 2`

		rlRun "ipa dnsrecord-add $DOMAIN dns175 --a-rec=192.168.0.1"
		newserial=`ipa dnszone-show $DOMAIN  --all --raw | grep -i idnssoaserial | cut -d :  -f 2`
		if [ $serial -eq $newserial ]; then
			rlFail "idnssoaserial has not changed, not as expected, GOT: $newserial"
		else
			rlPass "idnssoaserial has changed as expected, GOT: $newserial"
		fi

	rlRun "ipa dnsrecord-del $DOMAIN dns175 --a-rec=192.168.0.1"
	rlPhaseEnd

}

bz804562()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=804562
	rlPhaseStartTest "bz804562 --ns-hostname option does not check A/AAAA record of the provided hostname."
		verifyErrorMsg "ipa dnsrecord-add $DOMAIN dns176 --ns-hostname=ns1.shanks.$DOMAIN." "ipa: ERROR: Nameserver 'ns1.shanks.$DOMAIN.' does not have a corresponding A/AAAA record"

        rlPhaseEnd
}

bz795414()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=795414
	rlPhaseStartTest "bz795414 Dynamic database plug-in cannot change BIND root zone forwarders while plug-in start"
		rlAssertGrep "forwarders" "/etc/named.conf"
		rlRun "ipa dnszone-mod $DOMAIN --forwarder=10.65.202.128 --forwarder=10.65.202.129 --forward-policy=first" 

		rlRun "ipa dnszone-mod $DOMAIN --forwarder= --forward-policy=" 0 "Removing forwarders and forward-policy"

	rlPhaseEnd
}

bz805427()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=805427	
	rlPhaseStartTest "bz805427 idnssoaserial does not honour the recommended syntax in rfc1912."
		myzone="bugzone"
		FORMAT=`date +%Y%m%d`
		FORMAT=`date +%s`
		#trim any whitespace
		FORMAT=`echo $FORMAT`
		#rlRun "ipa dnszone-show $DOMAIN | grep -i serial | cut -d : -f 2 | grep $FORMAT"

                rlRun "ipa dnszone-add $myzone --name-server=$MASTER. --admin-email=$email"
		zoneSerial=`ipa dnszone-show $myzone | grep -i serial | cut -d : -f 2`
                #if [ $zoneSerial $FORMAT  ] ; then
                #else
                #fi

		rlRun "ipa dnszone-del $myzone"

	rlPhaseEnd
}

bz805871()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=805871
	rlPhaseStartTest "bz805871 Incorrect SOA serial number set for forward zone during ipa-server installation."
		host_s=`hostname -s`
		sshfprecord1=`ipa dnsrecord-show $DOMAIN $host_s --all --raw | grep sshfprecord | awk '{print $2,$3,$4;}' | sed -n '1p'`
		sshfprecord2=`ipa dnsrecord-show $DOMAIN $host_s --all --raw | grep sshfprecord | awk '{print $2,$3,$4;}' | sed -n '2p'`

		cat > /tmp/nsupdate.txt << EOF
zone $DOMAIN.
update delete $MASTER. IN SSHFP
send
update add $MASTER. 1200 IN SSHFP 1 1 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
update add $MASTER. 1200 IN SSHFP 2 1 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
send
EOF
		rlRun "kinit -k -t /etc/krb5.keytab host/$MASTER" 0 "Kinit with $MASTER keytab"
		rlRun "nsupdate -g /tmp/nsupdate.txt" 0 "EXECUTING: nsupdate -g /tmp/nsupdate.txt"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnszone-show $DOMAIN > /tmp/dnsshow.out 2>&1"
		serial=`cat /tmp/dnsshow.out | grep -i serial | awk '{print $3;}' | wc -m`
		if [ $serial -eq 11 ] ; then
			rlPass "Serial length as expected: $serial"
		else
			rlFail "Serial length not as expected.  GOT: $serial EXPECTED: 11"
		fi 
		expire=`cat /tmp/dnsshow.out | grep -i expire | awk '{print $3;}' | wc -m`
                if [ $expire -eq 8 ] ; then
                        rlPass "Expiration length as expected: $expire"
		else
			rlFail "Expiration length not as expected. GOT: $expire EXPECTED: 8"
                fi

		# revert to original

		if [ -z "$sshfprecord1" ];then

			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		else
			cat > /tmp/nsupdate.txt << EOF
zone $DOMAIN.
update delete $MASTER. IN SSHFP
send
update add $MASTER. 1200 IN SSHFP $sshfprecord1
update add $MASTER. 1200 IN SSHFP $sshfprecord2
send
EOF

			rlRun "kinit -k -t /etc/krb5.keytab host/$MASTER"
			rlRun "nsupdate -g /tmp/nsupdate.txt"

			rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		fi
	rlPhaseEnd
}

bz701677()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=701677
	rlPhaseStartTest "bz701677 Allow specifying query and transfer policy settings for a zone."
		currenteth=$(/sbin/ip -6 route show | grep ^default | awk '{print $5}' | head -1)
		MASTERIP=`dig +short $MASTER`
		#MASTERIP6=`ifconfig $currenteth | grep "inet6 " | grep -E 'Scope:Site|Scope:Global' | awk '{print $3}' | awk -F / '{print $1}' | sed -n '1p'`
		MASTERIP6=`hostname -I | awk '{print $2}'`

		rlRun "ipa dnszone-add example.com --name-server=$MASTER. --admin-email=$email"

		# Tests allow query '--allow-query'
		rlRun "echo \"ipa dnszone-mod example.com --allow-query='$MASTERIP;\!$MASTERIP6;'\" > /var/tmp/allow-query.sh"
		sed -i 's/\\//g' /var/tmp/allow-query.sh
		chmod +x /var/tmp/allow-query.sh
		rlRun "/var/tmp/allow-query.sh"


		rlRun "dig @$MASTERIP -t soa example.com | grep -i \"ANSWER SECTION\"" 0 "Allow query from $MASTERIP passed, as expected"
		rlRun "dig @$MASTERIP6 -t soa example.com | grep -i \"ANSWER SECTION\"" 1 "Allow query from $MASTERIP6 failed, as expected"

                rlRun "echo \"ipa dnszone-mod example.com --allow-query='$MASTERIP6;\!$MASTERIP;'\" > /var/tmp/allow-query.sh"
                sed -i 's/\\//g' /var/tmp/allow-query.sh
                chmod +x /var/tmp/allow-query.sh
                rlRun "/var/tmp/allow-query.sh"


                rlRun "dig @$MASTERIP -t soa example.com | grep -i \"ANSWER SECTION\"" 1 "Allow query from $MASTERIP failed, as expected"
                rlRun "dig @$MASTERIP6 -t soa example.com | grep -i \"ANSWER SECTION\"" 0 "Allow query from $MASTERIP6 passed, as expected"

		# Resetting to 'any'
                rlRun "ipa dnszone-mod example.com --allow-query='any;'"

		# Tests transfer policy '--allow-transfer'
		rlRun "echo \"ipa dnszone-mod example.com --allow-transfer='$MASTERIP;\!$MASTERIP6;'\" > /var/tmp/allow-transfer.sh"
                sed -i 's/\\//g' /var/tmp/allow-transfer.sh
                chmod +x /var/tmp/allow-transfer.sh
                rlRun "/var/tmp/allow-transfer.sh"


                rlRun "dig @$MASTERIP example.com axfr | grep -i \"Transfer failed\"" 1 "Allow zone transfer from $MASTERIP failed, as expected"
                rlRun "dig @$MASTERIP6 example.com axfr | grep -i \"Transfer failed\"" 0 "Allow zone transfer from $MASTERIP6 passed, as expected"
        
                rlRun "echo \"ipa dnszone-mod example.com --allow-transfer='$MASTERIP6;\!$MASTERIP;'\" > /var/tmp/allow-query.sh"
                sed -i 's/\\//g' /var/tmp/allow-query.sh
                chmod +x /var/tmp/allow-query.sh
                rlRun "/var/tmp/allow-query.sh"


                rlRun "dig @$MASTERIP example.com axfr | grep -i \"Transfer failed\"" 0 "Allow zone transfer from $MASTERIP passed, as expected" 
                rlRun "dig @$MASTERIP6 example.com axfr | grep -i \"Transfer failed\"" 1 "Allow zone transfer from $MASTERIP6 failed, as expected"

		# removing zone
		rlRun "ipa dnszone-del example.com"


	rlPhaseEnd
}

bz804572()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=804572
        rlPhaseStartTest "bz804572 Irrelevant error message when per-part modification mode is used during dnsrecord-mod operation without specifying the record."
                verifyErrorMsg "ipa dnsrecord-add lab.eng.pnq.redhat.com bumblebee --cname-hostname=zetaprime.lab.eng.pnq.redhat.com --cname-rec=" "ipa: ERROR: invalid 'cname_hostname': Raw value of a DNS record was already set by cname_rec option"
                verifyErrorMsg "ipa dnsrecord-mod lab.eng.pnq.redhat.com test5 --a-ip-address=10.65.201.190" "ipa: ERROR: 'arecord' is required"

        rlPhaseEnd
}

bz772301()
{
    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=772301
    rlPhaseStartTest "bz772301 Reverse DNS rec not created upon creation of fwd DNS rec"
        aaaa174="2620:52:0:2247:221:5eff:fe86:16b4"
        aaaarev="4.b.6.1.6.8.e.f.f.f.e.5.1.2.2.0"
        aaaa174rev="7.4.2.2.0.0.0.0.2.5.0.0.0.2.6.2.ip6.arpa."
        a174="10.1.1.10"
        arev="10"
        a174rev="1.1.10.in-addr.arpa."

        # add dns record - reverse zone does exist
	rlLog "EXECUTING: ipa dnszone-add $a174rev --name-server=$MASTER. --admin-email=$email"
        rlRun "ipa dnszone-add $a174rev --name-server=$MASTER. --admin-email=$email" 0 "Add ipv4 reverse zone"
	rlLog "EXECUTING: ipa dnsrecord-add $DOMAIN --a-create-reverse --a-rec=$a174 myhost"
        rlRun "ipa dnsrecord-add $DOMAIN --a-create-reverse --a-rec=$a174 myhost" 0 "Add ipv4 dns record"
	sleep 5
        rlRun "ipa dnsrecord-find $DOMAIN myhost" 0 "Verify ipv4 forward record was added"
        rlRun "ipa dnsrecord-find $a174rev 10" 0 "Verify ipv4 reverse record was added"
        rlRun "ipa dnsrecord-del $a174rev $arev --del-all" 0 "Delete reverse record"
        rlRun "ipa dnszone-del $a174rev" 0 "Cleanup ipv4 reverse zone added"
        #rlRun "ipa dnsrecord-del $DOMAIN myhost --del-all" 0 "Delete forward record"
        sleep 5

        # add dns record - reverse zone does exist - ipv6
	rlLog "EXECUTING: ipa dnszone-add $aaaa174rev --name-server=$MASTER. --admin-email=$email"
        rlRun "ipa dnszone-add $aaaa174rev --name-server=$MASTER. --admin-email=$email" 0 "Add ipv6 reverse zone"
	rlLog "EXECUTING: ipa dnsrecord-add testrelm.com --aaaa-ip-address=$aaaa174 --aaaa-create-reverse myhost"
        rlRun "ipa dnsrecord-add testrelm.com --aaaa-ip-address=$aaaa174 --aaaa-create-reverse myhost" 0 "Add ipv6 dns record"
	sleep 5
        rlRun "ipa dnsrecord-find $DOMAIN myhost" 0 "Verify ipv6 forward record was added"
        rlRun "ipa dnsrecord-find $aaaa174rev $aaaarev" 0 "Verify ipv6 reverse record was added"
        rlRun "ipa dnsrecord-del $aaaa174rev $aaaarev --del-all" 0 "Delete reverse record"
        rlRun "ipa dnszone-del $aaaa174rev" 0 "Delete reverse zone"
        rlRun "ipa dnsrecord-del $DOMAIN myhost --del-all" 0 "Delete forward record"
        sleep 5
    rlPhaseEnd
}

bz818933()
{

    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=818933
    rlPhaseStartTest "818933 bind-dyndb-ldap doesn't escape non-ASCII characters correctly"

	rlRun "dig foo,bar.$DOMAIN"
	rlRun "grep 'bug in handle_connection_error' /var/log/messages" 1 "Make sure bug has not shown up in /var/log/messages BA 818933"

        sleep 5
    rlPhaseEnd
}

bz767489()
{

    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=767489
    rlPhaseStartTest "767489 Periodically reconnect to LDAP when the first connection fails"

	named_ldapi_domain=`hostname -d | sed s/[.]/-/g | tr '[:lower:]' '[:upper:]'`

        rlRun "systemctl status named"
	rlRun "cp /etc/named.conf /root/"
	rlRun "sed -i 's/ldapi:\/\/\%2fvar\%2frun\%2fslapd-TESTRELM-COM.socket/ldapi:\/\/127.0.0.1/g' /etc/named.conf"
	rlRun "iptables -A INPUT -j REJECT -p TCP --destination-port ldap --reject-with icmp-port-unreachable"
	rlRun "iptables -A INPUT -j REJECT -p TCP --destination-port ldaps --reject-with icmp-port-unreachable"
	rlRun "iptables -L"

        rlRun "systemctl restart named"
        rlRun "systemctl status named"

	rlRun "iptables -F"
        rlRun "systemctl stop iptables"
	rlRun "mv -f /root/named.conf /etc/"
        rlRun "chgrp named /etc/named.conf"
        rlRun "systemctl restart named"

    rlPhaseEnd
}

bz802375()
{

    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=802375
    rlPhaseStartTest "802375 BIND cannot be shutdown correctly, if psearch is enabled and LDAP connect fails"

	rlAssertGrep "psearch yes" "/etc/named.conf"
        rlRun "systemctl status named"
        rlRun "cp /etc/named.conf /root/"
        rlRun "sed -i 's/ldapi:\/\/\%2fvar\%2frun\%2fslapd-TESTRELM-COM.socket/ldapi:\/\/127.0.0.1/g' /etc/named.conf"
        rlRun "systemctl restart named"
	rlRun "rndc stop"

        rlRun "systemctl status named" 3 "Verifying that named is not running"

        rlRun "mv -f /root/named.conf /etc/"
        rlRun "chgrp named /etc/named.conf"
        rlRun "systemctl restart named"

    rlPhaseEnd
}

bz767496()
{
    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=767496
    rlPhaseStartTest "767496 assertion failure when using persistent search"

        rlAssertGrep "psearch yes" "/etc/named.conf"
        rlRun "systemctl status named" 0 "get named status"
        rlRun "systemctl stop named" 0 "stop named"
        rlRun "iptables-save > /tmp/iptables.backup" 0 "save iptables"
        rlRun "iptables -I INPUT -p tcp --dport 389 -j REJECT" 0 "add rule for port 389"
        rlRun "iptables -I INPUT -p tcp --dport 636 -j REJECT" 0 "add rule for port 636"
        rlRun "systemctl restart named"  0 "restart named"
        rlRun "rndc reload" 0 " rndc reload was successful"

        #restore back:
        rlRun "systemctl stop named"  0 "stop named"
        rlRun "iptables-restore -c /tmp/iptables.backup" 0 "restore iptables" 
        rlRun "systemctl restart named"

    rlPhaseEnd

}


bz805430()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=805430
	rlPhaseStartTest "805430 IPA dnszone-add does not accept the utmost valid serial number."

		kdestroy
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		outfile="/opt/rhqa_ipa/utmosr-zone-addtest.txt"
		ipa dnszone-add --name-server=$MASTER. --serial=4294123199 --admin-email=admin@$DOMAIN maxtzone &> $outfile
		ipa dnszone-del maxtzone
		rlRun "ipa dnszone-add --name-server=$MASTER. --serial=4294123199 --admin-email=admin@$DOMAIN maxtzone" 0 "test to make sure the maxtzone dnszone-add returns 0"
		rlRun "grep 'can be at most' $outfile" 1 "check output of dnszone-add for error message"
		ipa dnszone-del maxtzone

	rlPhaseEnd
}	

bz819635()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=819635
	# There may be a better way to do this. 
	rlPhaseStartTest "819635 Verify a help page change"
		kdestroy
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnszone-mod --help | grep 'forwarder=STR' | grep global\ forwarders" 1 "Ensure old string does not exist in help section"
		rlRun "ipa dnszone-mod --help | grep 'forwarder=STR' | grep -i per-zone\ forwarders" 0 "Ensure new string does not exist in help section"

	rlPhaseEnd
}
	
bz809562()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=809562
	rlPhaseStartTest "809562 Constraints for CNAME records are not enforced "
		kdestroy
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnsrecord-add $DOMAIN tt --a-rec=1.2.3.4" 0 "Add a A record to conflict with the cname record"
		rlRun "ipa dnsrecord-find $DOMAIN tt | grep A\ record" 0 "Make sure the A record was created"
		rlRun "ipa dnsrecord-add $DOMAIN tt --cname-rec='tt.$DOMAIN'" 1 "Attempt to add a cname record, this should fail"
		rlRun "ipa dnsrecord-find $DOMAIN tt | grep CNAME\ record" 1 "Make sure the CNAME record was not created"
		rlRun "ipa dnsrecord-del $DOMAIN tt --a-rec=1.2.3.4" 0 "Delete the A record that conflict with the cname record"
		rlRun "ipa dnsrecord-find $DOMAIN tt | grep A\ record" 1 "Make sure the A record was removed"
		rlRun "ipa dnsrecord-add $DOMAIN tt --cname-rec='tt.$DOMAIN'" 0 "Adding a cname record"
		rlRun "ipa dnsrecord-find $DOMAIN tt | grep CNAME\ record" 0 "Make sure the CNAME record was created"
		rlRun "ipa dnsrecord-add $DOMAIN tt --a-rec=1.2.3.4" 1 "Attempt to create a A record to conflict with the CNAME record."
		rlRun "ipa dnsrecord-find $DOMAIN tt | grep A\ record" 1 "Make sure the A record was not created"
		ipa dnsrecord-del $DOMAIN tt --cname-rec="tt.$DOMAIN"
	rlPhaseEnd
}

bz828687()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=828687
	rlPhaseStartTest "828687 Unable to update dns when deleting host"
		ipaddr=$(hostname -i)
		rlLog "Ip address is $ipaddr"
		ipoc1=$(echo $ipaddr | cut -d\. -f1)
		ipoc2=$(echo $ipaddr | cut -d\. -f2)
		ipoc3=$(echo $ipaddr | cut -d\. -f3)
		ipoc4=$(echo $ipaddr | cut -d\. -f4)
		newoc4=252
		temail="ipaqar.redhat.com"
		tserial=2010010701
		trefresh=303
		tretry=101
		texpire=1202
		tminimum=33
		tttl=55
		tzone="llnewzone."
		thn=$(hostname)
		tipaddr="$thn." # Add a . to the end of the address to test with

		# Add a zone to test with
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 0 "Adding a new zone to test with"
		# Add a host to test with
		rlRun "ipa host-add --ip-address='$ipoc1.$ipoc2.$ipoc3.$newoc4' 'tt.$tzone'" 0 "Add a new host to test with"
		rlRun "ipa dnsrecord-find $ipoc3.$ipoc2.$ipoc1.in-addr.arpa. $newoc4 | grep $tzone" 0 "Make sure PTR record was added for the new host."
		rlRun "ipa host-del tt.$tzone --updatedns" 0 "Try to delete the new host. This should pass"
	
		# Cleanup
		ipa dnsrecord-del $ipoc3.$ipoc2.$ipoc1.in-addr.arpa. $newoc4 --ptr-rec="tt.$tzone."
		ipa host-del tt.$tzone
		ipa dnszone-del $tzone
	rlPhaseEnd
}

bz817413()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=817413
	# A domain:
	# 1. Can't have an empty component: sub..domain.com
	# 2. top-level domain must be alphabetic: sub.123
	# 3. Valid characters are a-z0-9. dash is allowed but it can't be first or last.
	# 4. An component can't be longer than 63 characters.
        # 03/26 Update: Condition 2 is dropped - discussed with akrivoka, pspacek
	rlPhaseStartTest "817413: test of invalid characters in domain name"
		temail="ipaqar.redhat.com"
		tserial=2010010701
		trefresh=303
		tretry=101
		texpire=1202
		tminimum=33
		tttl=55
		tzone="llnewzone"

		# 1.
		# Attempt adding a zone with a empty component
		tzone="domain..empty.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a empty component"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created
		
		# 2.
		# Attempt adding a zone with a numeric TLD
		tzone="domain.numeric.123"
		rlLog "Executing: ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 0 "adding a domain with a numeric TLD"
		rlRun "ipa dnszone-find $tzone" 0 "ensure that ipa can find the zone."
		ipa dnszone-del $tzone # Cleanup the zone 

		# 3.
		# Attempt adding a zone with a dash at the start
		tzone='\-domain.dash.com'
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl '$tzone'" 1 "Attempt adding a domain with dash at the front"
		rlRun "ipa dnszone-find '$tzone'" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a zone with a dash at the end
		tzone="domain.dash.com-"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with dash at the end"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a zone with a dash a bad character
		tzone="domain.badchar^.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a bad char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a zone with a dash a different bad character
		tzone="domain.badchar#.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a bad char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a zone with a dash a different bad character
		tzone="domain.badchar$.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a bad char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a zone with a dash a different bad character
		tzone="domain.badchar*.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a bad char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# 4.
		# Attempt adding a domain with any element longer than 63 char
		tzone="domain.sixthreemax.12345678901234567890123345678901234567890123456789012345678901234567890.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a element longer than 63 char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a domain with any element longer than 63 char
		tzone="firstlkjhjklasghduygasiudfygvq7i6ertf78q6t4871y8347y2r8734y87aylfisduhcvkljasnkljnasdljdnclakj.long.com"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a element longer than 63 char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		# Attempt adding a domain with TLD longer than 63 char
		tzone="long.tld.tldlkjhjklasghduygasiudfygvq7i6ertf78q6t4871y8347y2r8734y87aylfisduhcvkljasnkljnasdljdnclakj"
		rlRun "ipa dnszone-add --name-server=$tipaddr --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 1 "Attempt adding a domain with a element longer than 63 char"
		rlRun "ipa dnszone-find $tzone" 1 "ensure that ipa cannot find the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

	rlPhaseEnd
}

bz813380()
{
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=813380
	# Bug 813380 - Improve NS record validation of non-fqdn records
	rlPhaseStartTest "Bug 813380 - Improve NS record validation of non-fqdn records"
		ipaddr=$(hostname -i)
		rlLog "Ip address is $ipaddr"
		ipoc1=$(echo $ipaddr | cut -d\. -f1)
		ipoc2=$(echo $ipaddr | cut -d\. -f2)
		ipoc3=$(echo $ipaddr | cut -d\. -f3)
		ipoc4=$(echo $ipaddr | cut -d\. -f4)
		#newoc4=251
                # NK:
		newoc4=252
		temail="ipaqar.redhat.com"
		tserial=2010010701
		trefresh=303
		tretry=101
		texpire=1202
		tminimum=33
		tttl=55
		tzone="llnewzone.com"

		# Add a zone to test with
		rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 0 "Add a new zone to test with"
		# Create a host to add as a NS to the new zone
		rlRun "ipa host-add nsnew.$tzone --ip-address=$ipoc1.$ipoc2.$ipoc3.$newoc4" 0 "Add a host to add as a ns server for the zone $tzone"
		rlRun "ipa host-find nsnew.$tzone" 0 "make sure that the new host was created"
		rlRun "ipa dnsrecord-add $tzone @ --ns-rec=nsnew" 0 "Add a non-FQDN NS record to the new zone"
		rlRun "ipa dnsrecord-show $tzone @ | grep nsnew" 0 "Make sure that the ns record appears in the new zone"
		ipa host-del nsnew.$tzone --updatedns # Cleanup the host
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

	rlPhaseEnd	
}

bz829340()
{
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=829340
	# Bug 829340 - plugin doesn't handle IPv6 elements in idnsForwarders attribute
	rlPhaseStartTest "Bug 829340 - check support for IPv6 elements in idnsForwarders attribute"
		temail="ipaqar.redhat.com"
		tserial=2010010701
		trefresh=303
		tretry=101
		texpire=1202
		tminimum=33
		tttl=55
		tzone="idnszone.com"
		ipv6address1='2002::210:14ff:fe05:134'
		ipv6address2='2002::210:14ff:fe05:135'
		ipv6address=$ipv6address1
		ipv6host=$ipa6address1

		# Add a zone to test with
		rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 0 "Add a new zone to test with"
		rlRun "ipa dnszone-mod $tzone --addattr=idnsForwarders='$ipv6address'" 0 "add a IPv6 address to the idns Forwarders field of a zone."
		rlRun "ipa dnszone-find $tzone | grep Zone\ forwarders | grep '$ipv6address'" 0 "Make sure that the IPv6 address appears to be part of the zone."
		ipa dnszone-del $tzone # Cleanup the zone in case it was created

		if [ ! -x $BEAKERSLAVE ]; then
			rlLog "NOTICE - Slave detected as $BEAKERSLAVE"
			# Figure out what interface to use for the next steps
			cat /proc/net/dev | grep -v Inter | grep -v face | grep -v lo | grep -v br0 | cut -d : -f 1 | sed s/\ //g | while read if; do 
				# Look for a internet interface taht has a address
				ifconfig $if | grep inet\ addr
				if [ $? -eq 0 ]; then 
					inetinterface=$if
				fi 
			done	

			hn=$(hostname -s)
			echo $BEAKERMASTER | grep $hn
			if [ $? -eq 0 ]; then
				rlLog "This is the master. Setting rhts sync block"
				rlRun "rhts-sync-set -s 'bz.dns.829340' -m $BEAKERMASTER"
				rlLog "setting ipv6 address on interface $inetinterface to $ipv6address1"
				/sbin/ip -6 addr add $ipv6address1/64 dev $inetinterface
				ipa dnszone-del $tzone
				rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 0 "Add a new zone to test with"
				rlRun "ipa dnszone-mod $tzone --addattr=idnsForwarders='$ipv6address2'" 0 "add a IPv6 address to the idns Forwarders field of a zone."
	
				rlRun "rhts-sync-block -s 'bz.dns.829340.b' $BEAKERSLAVE"

				# ipv6 cleanup
				/sbin/ip -6 addr del $ipv6address1/64 dev $inetinterface
			else
				rlLog "This is the slave. waiting for the master"
				rlRun "rhts-sync-block -s 'bz.dns.829340' $BEAKERMASTER"
				rlLog "setting ipv6 address on interface $inetinterface to $ipv6address2"
				/sbin/ip -6 addr add $ipv6address2/64 dev $inetinterface
				
				rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
			 
				# Add host
				# verify resolvable from slave

				rlRun "rhts-sync-set -s 'bz.dns.829340.b' -m $BEAKERSLAVE"

				# ipv6 cleanup
				/sbin/ip -6 addr del $ipv6address2/64 dev $inetinterface
			fi
		else
			rlLog "NOTICE - No slave detected. Not running multi host tests for bug 829340"
		fi
	rlPhaseEnd
}

bz798493()
{
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=798493
	# Bug 798493 - adding reverse zones in gui fails to create correct zone 
	rlPhaseStartTest "Bug 798493 - adding reverse zones in gui fails to create correct zone"
		# Add a zone
		forward='10.11.12.0/24'
		reverse='12.11.10.in-addr.arpa.'
		echo '' | ipa dnszone-add --name-server=`hostname`. --admin-email="admin@testrelm.com" --name-from-ip=$forward
		rlRun "ipa dnszone-find '$reverse'" 0 "Make sure dnszone-find seems to find the reverse zone"
		rlRun "ipa dnszone-find '$reverse' | grep 'Zone name: $reverse'" 0 "Make sure dnszone-find outputs teh correct zone name."
		ipa dnszone-del $reverse
		# Add a zone
		forward='10.11.12.0/20'
		reverse='11.10.in-addr.arpa.'
		echo '' | ipa dnszone-add --name-server=`hostname`. --admin-email="admin@testrelm.com" --name-from-ip=$forward
		rlRun "ipa dnszone-find '$reverse'" 0 "Make sure dnszone-find seems to find the reverse zone"
		rlRun "ipa dnszone-find '$reverse' | grep 'Zone name: $reverse'" 0 "Make sure dnszone-find outputs teh correct zone name."
		ipa dnszone-del $reverse
		# Add a zone
		forward='10.11.12.0/16'
		reverse='11.10.in-addr.arpa.'
		echo '' | ipa dnszone-add --name-server=`hostname`. --admin-email="admin@testrelm.com" --name-from-ip=$forward
		rlRun "ipa dnszone-find '$reverse'" 0 "Make sure dnszone-find seems to find the reverse zone"
		rlRun "ipa dnszone-find '$reverse' | grep 'Zone name: $reverse'" 0 "Make sure dnszone-find outputs teh correct zone name."
		ipa dnszone-del $reverse

	rlPhaseEnd
}

bz809565()
{
	# Test for https://bugzilla.redhat.com/show_bug.cgi?id=809565
	rlPhaseStartTest "Bug 809565 - Cannot change DNS name without recreating it"
		temail="ipaqar.redhat.com"
		tserial=2010010701
		trefresh=303
		tretry=101
		texpire=1202
		tminimum=33
		tttl=55
		tzone="idnszone.com"
                recordName="ARecord"
                newRecordName="ARenameRecord"
                recordName2="cRecord"
                newRecordName2="cRenameRecord"
		ipaddr=$(hostname -i)
		rlLog "Ip address is $ipaddr"
		ipoc1=$(echo $ipaddr | cut -d\. -f1)
		ipoc2=$(echo $ipaddr | cut -d\. -f2)
		ipoc3=$(echo $ipaddr | cut -d\. -f3)
		ipoc4=$(echo $ipaddr | cut -d\. -f4)
		newoc4=251

		# Add a zone to test with
		rlLog "Executing: ipa dnszone-add --name-server=$MASTER. --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone"
		rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$temail --serial=$tserial --refresh=$trefresh --retry=$tretry --expire=$texpire --minimum=$tminimum --ttl=$tttl $tzone" 0 "Add a new zone to test with"

                # Add an A Record
                rlRun "ipa dnsrecord-add $tzone $recordName --a-ip-address=$ipoc1.$ipoc2.$ipoc3.$newoc4" 0 "Add ARecord"
                rlRun "ipa dnsrecord-find $tzone | grep $recordName" 0 "Verify dnsrecord $recordName is added"
                # Rename this record
                rlRun "ipa dnsrecord-mod $tzone $recordName --rename $newRecordName" 0 "Rename $recordName to be $newRecordName"
                
                rlRun "ipa dnsrecord-find $tzone | grep $recordName" 1 "Verify dnsrecord $recordName is not found"
                rlRun "ipa dnsrecord-find $tzone | grep $newRecordName" 0 "Verify renamed dnsrecord $newRecordName is found"

                # Add an CNAME Record to test with
                rlRun "ipa dnsrecord-add $tzone $recordName2 --cname-rec=$newRecordName.$DOMAIN." 0 "Add cname Record"
                rlRun "ipa dnsrecord-find $tzone | grep --after-context=1 $recordName2 | grep $newRecordName" 0 "Verify dnsrecord $recordName2 is added"
                # Rename this record
                rlRun "ipa dnsrecord-mod $tzone $recordName2 --rename $newRecordName2" 0 "Rename $recordName2 to be $newRecordName2"
                
                rlRun "ipa dnsrecord-find $tzone | grep $recordName2 | grep $newRecordName" 1 "Verify dnsrecord $recordName2 is not found"
                rlRun "ipa dnsrecord-find $tzone | grep --after-context=1 $newRecordName2 | grep $newRecordName" 0 "Verify renamed dnsrecord $newRecordName is found"

		ipa dnszone-del $tzone # Cleanup the zone in case it was created
		
	rlPhaseEnd
}

bz829388()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=829388
	rlPhaseStartTest "Bug 829388 - Zone transfers fail for certain non-FQDNs"
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		rlRun "ipa dnszone-mod $DOMAIN --allow-transfer='any;'" 0 "Enable DNS zone transfers"
		host="bz829388"
		rlRun "ipa dnsrecord-add $DOMAIN $host --cname-rec=$host" 0 "Add a dns record to test zone transfers with"
		rlRun "dig -t AXFR @$MASTER $DOMAIN | grep $host.$DOMAIN." 0 "Ensure that $host.$DOMAIN is in the list of AXFR records as a FQDN BZ 829388"
		rlRun "ipa dnsrecord-del $DOMAIN $host --cname-rec=$host" 0 "Cleanup added DNS record."
		rlRun "ipa dnszone-mod $DOMAIN --allow-transfer='none;'" 0 "Reset DNS zone transfers setting"
	rlPhaseEnd
}

bz829353()
{
     rlPhaseStartTest "bz829353 - bind-dyndb-ldap crashes when NS is not resolvable"
        rlLog "Executing: ipa dnszone-add --name-server=unused-4-107.brq.redhat.com. --admin-email=$email e.test"
        rlRun "ipa dnszone-add --name-server=unused-4-107.brq.redhat.com. --admin-email=$email e.test" 0 "Add zone with non-resolvable name server"
        rlLog "Executing: ipa dnszone-del e.test"
        rlRun "ipa dnszone-del e.test" 0 "Delete this zone"
        rlLog "Executing: dig @$MASTERIP e.test | grep \"no servers could be reached\" "
        rlRun "dig @$MASTERIP e.test | grep \"no servers could be reached\" " 1 "Verify service named is running"
        rlLog "Executing: dig @$MASTERIP e.test | grep \"SERVFAIL\" "
        rlRun "dig @$MASTERIP e.test | grep \"SERVFAIL\" " 1 "Verify tkt #92 Incorrect DNS zones are not unloaded correctly (e.g. with invalid NS records)"
     rlPhaseEnd

}

bz840383()
{
     zone840383="zone840383.testrelm.com"
     txt="\"bug test\""
     newtxt="\"Bug Test for 840383\""
     ipaddr="$MASTER."
     rlPhaseStartTest "bz840383 - Implement SOA serial number increments for external changes"
       	rlLog "Executing: ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone840383" 
       	rlRun "ipa dnszone-add --name-server=$ipaddr --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone840383" 0 "Add a new zone to test with"
        rlLog "Executing: ipa dnsrecord-add $zone840383 txt --txt-rec $txt"
        rlRun "ipa dnsrecord-add $zone840383 txt --txt-rec $txt" 0 "add record type txt"
        rlLog "Executing: ipa dnszone-mod $zone840383 --allow-transfer='any;'"
        rlRun "ipa dnszone-mod $zone840383 --allow-transfer='any;'" 0 "Allow zone transfers"
        rlLog "Executing: dig @$MASTERIP -t AXFR $zone840383 | grep \"TXT\" "
        rlRun "dig @$MASTERIP -t AXFR $zone840383 | grep \"TXT\" " 0 "Verify the TXT record is part of zone transfer"
	oldserial=`dig $zone840383 +multiline -t SOA | grep serial | cut -d ";" -f1 | xargs echo`
        rlLog "Executing: ipa dnsrecord-mod $zone840383 txt --txt-rec=$txt --txt-data=$newtxt"
        rlRun "ipa dnsrecord-mod $zone840383 txt --txt-rec=$txt --txt-data=$newtxt" 0 "update record type txt"
	newserial=`dig $zone840383 +multiline -t SOA | grep serial | cut -d ";" -f1 | xargs echo`
        if [ $oldserial -gt $newserial ]; then
             rlFail "new serial after updating record is not higher. Was: $oldserial; New: $newserial"
        else
             rlPass "new serial after updating record is higher. Was: $oldserial; New: $newserial"
        fi
        rlLog "Executing: ipa dnszone-mod --dynamic-update=true $zone840383"
        rlRun "ipa dnszone-mod --dynamic-update=true $zone840383" 0 "Update idnsAllowDynUpdate attribute" 
	currentserial=`dig $zone840383 +multiline -t SOA | grep serial | cut -d ";" -f1 | xargs echo`
        if [ $currentserial -eq $newserial ]; then
             rlPass "serial was not updated when idnsAllowDynUpdate attr was updated "
        else
             rlFail "new serial after updating idnsAllowDynUpdate attribute. Was: $newserial; New: $currentserial"
        fi
     rlPhaseEnd
     # Cleanup
     ipa dnszone-del $zone840383
}

bz829728()
{
    rlPhaseStartTest "bz829728 - Crash on reload with persistent search enabled"
       rlLog "Executing: export KRB5_KTNAME=\"/etc/named.keytab\""
       rlRun "export KRB5_KTNAME=\"/etc/named.keytab\"" 0 "export KRB5_KTNAME"
       rlLog "Executing: named -u named -d 0"
       rlRun "named -u named -d 0" 0 "run named as user named"
       rlLog "Executing: rndc reload"
       rlRun "rndc reload" 0 " rndc reload was successful"
       rlLog "Executing: systemctl status named"
       rlRun "systemctl status named" 0 "Verifying that named is running"
    rlPhaseEnd
}


dnsbugcleanup()
{
   	rlPhaseStartTest "dns bug cleanup"
		rlRun "ipa dnszone-del $zone" 0 "Delete test zone: $zone"
	rlPhaseEnd
}

