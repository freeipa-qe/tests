
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
   bz701677
   bz804572
   bz772301
   bz818933
   bz767489
   bz802375
   bz805430
   bz819635
   bz809562
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
	rlRun "ipa dnszone-add --name-server=$MASTER --admin-email=$email $zone" 0 "Add test zone: $zone"
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
		rlRun "service named restart" 0 "Restart named"
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
		rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=admin@example.com --allow-dynupdate | grep \"ipa: error: no such option: --allow-dynupdate\"" 1

		rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=admin@example.com --dynamic-update"
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

		rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=admin@example.com"
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
		rlRun "service named restart"
		rlRun "dig +short -t A foo.example.com | grep 10.0.0.1"

		rlLog "verifies https://bugzilla.redhat.com/show_bug.cgi?id=751776"

		rlRun "ipa dnszone-del example.com"
		rlRun "service named restart"

	rlPhaseEnd
}

bz797561()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=797561
	rlPhaseStartTest "bz797561 Bool attributes used in setattr/addattr/delattr options are not encoded properly"
		rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=admin@example.com"
                rlRun "ipa dnszone-show example.com --all --raw | grep -i \"idnsallowdynupdate: FALSE\""
		
		verifyErrorMsg "ipa dnszone-mod example.com --addattr=idnsAllowDynUpdate=true" "ipa: ERROR: idnsallowdynupdate: Only one value allowed."
		rlRun "ipa dnszone-show example.com --all --raw | grep -i \"idnsallowdynupdate: FALSE\""

		rlRun "ipa dnszone-mod example.com --setattr=idnsAllowDynUpdate=true"
		rlRun "ipa dnszone-show example.com --all --raw | grep -i \"idnsallowdynupdate: TRUE\""

		rlRun "ipa dnszone-del example.com"
                rlRun "service named restart"

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
                rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=admin@example.com"
		rlRun "ipa dnszone-mod example.com --admin-email=foo.bar@example.com"
		rlRun "ipa dnszone-show example.com | grep \"Administrator e-mail address: foo\\\\\.bar.example.com.\""
		rlRun "ipa dnszone-del example.com"
	rlPhaseEnd
}

bz733371()
{
	rlPhaseStartTest "bz733371 DNS zones are not loaded when idnsAllowQuery/idnsAllowTransfer is filled"
		MASTERIP=`dig +short $MASTER`
		rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=admin@example.com"
                rlRun "ipa dnsrecord-add example.com foo --a-rec=10.0.1.1"
		rlRun "ipa dnszone-mod example.com --allow-query=$MASTERIP"
		rlRun "service named reload"
		sleep 5
                rlRun "dig +short -t A foo.example.com | grep 10.0.1.1"
		rlRun "ipa dnszone-mod example.com --allow-query=10.0.1.1"
		rlRun "service named reload"
                sleep 5
                rlRun "nslookup foo.example.com | grep \"server can't find foo.example.com\""
                rlRun "ipa dnszone-del example.com"
        rlPhaseEnd
}

bz767492()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=767492
        rlPhaseStartTest "bz767492 The plugin doesn't delete zone when it is deleted in LDAP and zone_refresh is set"
		rlRun "ipa dnszone-add unknownexample.com --name-server=$MASTER --admin-email=admin@unknownexample.com"
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
		rlRun "ipa dnszone-add $a174rev --name-server=$MASTER --admin-email=$email"

		rlRun "ipa dnsrecord-add $DOMAIN foo --a-rec=$a174 --a-create-reverse"
		rlRun "ipa dnsrecord-show $a174rev 10 | grep \"PTR record: foo.$DOMAIN\""
		rlRun "service named restart"
		sleep 5
		rlRun "dig -x $a174 | grep foo.$DOMAIN"

		# for IPv4 -ve
		verifyErrorMsg "ipa dnsrecord-add $DOMAIN foo --a-rec=$a174 --a-create-reverse" "ipa: ERROR: Reverse record for IP address $a174 already exists in reverse zone $a174rev."
		rlRun "ipa dnsrecord-add $DOMAIN foo2 --a-rec=10.1.2.10 --a-create-reverse | grep \"ipa: ERROR: Cannot create reverse record for \"10.1.2.10\": DNS reverse zone for IP address 10.1.2.10 not found\"" 1

		# record clean-up
		rlRun "ipa dnsrecord-del $a174rev 10 --del-all"

		# for IPv6 +ve
		rlRun "ipa dnszone-add $aaaa174rev --name-server=$MASTER --admin-email=$email"
		rlRun "ipa dnsrecord-add $DOMAIN bar --aaaa-rec=$aaaa174 --aaaa-create-reverse"
		rlRun "ipa dnsrecord-show $aaaa174rev 4.b.6.1.6.8.e.f.f.f.e.5.1.2.2.0 | grep \"PTR record: bar.$DOMAIN\""
		rlRun "service named restart"
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
		rlRun "ipa dnszone-show $DOMAIN"
		serial=`ipa dnszone-show $DOMAIN  --all --raw | grep idnssoaserial | cut -d :  -f 2`

		rlRun "ipa dnsrecord-add $DOMAIN dns175 --a-rec=192.168.0.1"
		newserial=`ipa dnszone-show $DOMAIN  --all --raw | grep idnssoaserial | cut -d :  -f 2`
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
		rlRun "ipa dnszone-mod $DOMAIN --forwarder=10.65.202.128,10.65.202.129 --forward-policy=first" 
		rlRun "service named restart"

		rlRun "ipa dnszone-mod $DOMAIN --forwarder= --forward-policy=" 0 "Removing forwarders and forward-policy"

	rlPhaseEnd
}

bz805427()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=805427	
	rlPhaseStartTest "bz805427 idnssoaserial does not honour the recommended syntax in rfc1912."
		myzone="bugzone"
		FORMAT=`date +%Y%m%d`
		#trim any whitespace
		FORMAT=`echo $FORMAT`
		rlRun "ipa dnszone-show $DOMAIN | grep -i serial | cut -d : -f 2 | grep $FORMAT"

                rlRun "ipa dnszone-add $myzone --name-server=$MASTER --admin-email=$email"
		rlRun "ipa dnszone-show $myzone | grep -i serial | cut -d : -f 2 | grep $FORMAT"

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

		rlRun "ipa dnszone-add example.com --name-server=$MASTER --admin-email=$email"

		# Tests allow query '--allow-query'
		rlRun "echo \"ipa dnszone-mod example.com --allow-query='$MASTERIP;\!$MASTERIP6;'\" > /var/tmp/allow-query.sh"
		sed -i 's/\\//g' /var/tmp/allow-query.sh
		chmod +x /var/tmp/allow-query.sh
		rlRun "/var/tmp/allow-query.sh"

		rlRun "service named restart"

		rlRun "dig @$MASTERIP -t soa example.com | grep -i \"ANSWER SECTION\"" 0 "Allow query from $MASTERIP passed, as expected"
		rlRun "dig @$MASTERIP6 -t soa example.com | grep -i \"ANSWER SECTION\"" 1 "Allow query from $MASTERIP6 failed, as expected"

                rlRun "echo \"ipa dnszone-mod example.com --allow-query='$MASTERIP6;\!$MASTERIP;'\" > /var/tmp/allow-query.sh"
                sed -i 's/\\//g' /var/tmp/allow-query.sh
                chmod +x /var/tmp/allow-query.sh
                rlRun "/var/tmp/allow-query.sh"

                rlRun "service named restart"

                rlRun "dig @$MASTERIP -t soa example.com | grep -i \"ANSWER SECTION\"" 1 "Allow query from $MASTERIP failed, as expected"
                rlRun "dig @$MASTERIP6 -t soa example.com | grep -i \"ANSWER SECTION\"" 0 "Allow query from $MASTERIP6 passed, as expected"

		# Resetting to 'any'
                rlRun "ipa dnszone-mod example.com --allow-query='any;'"

		# Tests transfer policy '--allow-transfer'
		rlRun "echo \"ipa dnszone-mod example.com --allow-transfer='$MASTERIP;\!$MASTERIP6;'\" > /var/tmp/allow-transfer.sh"
                sed -i 's/\\//g' /var/tmp/allow-transfer.sh
                chmod +x /var/tmp/allow-transfer.sh
                rlRun "/var/tmp/allow-transfer.sh"

                rlRun "service named restart"

                rlRun "dig @$MASTERIP example.com axfr | grep -i \"Transfer failed\"" 1 "Allow zone transfer from $MASTERIP failed, as expected"
                rlRun "dig @$MASTERIP6 example.com axfr | grep -i \"Transfer failed\"" 0 "Allow zone transfer from $MASTERIP6 passed, as expected"
        
                rlRun "echo \"ipa dnszone-mod example.com --allow-transfer='$MASTERIP6;\!$MASTERIP;'\" > /var/tmp/allow-query.sh"
                sed -i 's/\\//g' /var/tmp/allow-query.sh
                chmod +x /var/tmp/allow-query.sh
                rlRun "/var/tmp/allow-query.sh"

                rlRun "service named restart"

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
	rlLog "EXECUTING: ipa dnszone-add $a174rev --name-server=$MASTER --admin-email=$email"
        rlRun "ipa dnszone-add $a174rev --name-server=$MASTER --admin-email=$email" 0 "Add ipv4 reverse zone"
	rlLog "EXECUTING: ipa dnsrecord-add $DOMAIN --a-create-reverse --a-rec=$a174 myhost"
        rlRun "ipa dnsrecord-add $DOMAIN --a-create-reverse --a-rec=$a174 myhost" 0 "Add ipv4 dns record"
	sleep 5
        rlRun "ipa dnsrecord-find $DOMAIN myhost" 0 "Verify ipv4 forward record was added"
        rlRun "ipa dnsrecord-find $a174rev 10" 0 "Verify ipv4 reverse record was added"
        rlRun "ipa dnsrecord-del $a174rev $arev --del-all" 0 "Delete reverse record"
        rlRun "ipa dnszone-del $a174rev" 0 "Cleanup ipv4 reverse zone added"
        #rlRun "ipa dnsrecord-del $DOMAIN myhost --del-all" 0 "Delete forward record"
        service named restart
        sleep 5

        # add dns record - reverse zone does exist - ipv6
	rlLog "EXECUTING: ipa dnszone-add $aaaa174rev --name-server=$MASTER --admin-email=$email"
        rlRun "ipa dnszone-add $aaaa174rev --name-server=$MASTER --admin-email=$email" 0 "Add ipv6 reverse zone"
	rlLog "EXECUTING: ipa dnsrecord-add testrelm.com --aaaa-ip-address=$aaaa174 --aaaa-create-reverse myhost"
        rlRun "ipa dnsrecord-add testrelm.com --aaaa-ip-address=$aaaa174 --aaaa-create-reverse myhost" 0 "Add ipv6 dns record"
	sleep 5
        rlRun "ipa dnsrecord-find $DOMAIN myhost" 0 "Verify ipv6 forward record was added"
        rlRun "ipa dnsrecord-find $aaaa174rev $aaaarev" 0 "Verify ipv6 reverse record was added"
        rlRun "ipa dnsrecord-del $aaaa174rev $aaaarev --del-all" 0 "Delete reverse record"
        rlRun "ipa dnszone-del $aaaa174rev" 0 "Delete reverse zone"
        rlRun "ipa dnsrecord-del $DOMAIN myhost --del-all" 0 "Delete forward record"
        service named restart
        sleep 5
    rlPhaseEnd
}

bz818933()
{

    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=818933
    rlPhaseStartTest "818933 bind-dyndb-ldap doesn't escape non-ASCII characters correctly"

	rlRun "dig foo,bar.$DOMAIN"
	rlAssertGrep "bug in handle_connection_error" "/var/log/messages"

        service named restart
        sleep 5
    rlPhaseEnd
}

bz767489()
{

    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=767489
    rlPhaseStartTest "767489 Periodically reconnect to LDAP when the first connection fails"

	named_ldapi_domain=`hostname -d | sed s/[.]/-/g | tr '[:lower:]' '[:upper:]'`

	rlRun "service named status"
	rlRun "cp /etc/named.conf /root/"
	rlRun "sed -i 's/ldapi:\/\/\%2fvar\%2frun\%2fslapd-TESTRELM-COM.socket/ldapi:\/\/127.0.0.1/g' /etc/named.conf"
	rlRun "iptables -A INPUT -j REJECT -p TCP --destination-port ldap --reject-with icmp-port-unreachable"
	rlRun "iptables -A INPUT -j REJECT -p TCP --destination-port ldaps --reject-with icmp-port-unreachable"
	rlRun "iptables -L"

	rlRun "service named restart"
	rlRun "service named status"

	rlRun "iptables -F"
	rlRun "service iptables stop"
	rlRun "mv -f /root/named.conf /etc/"
	rlRun "service named restart"

    rlPhaseEnd
}

bz802375()
{

    # Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=802375
    rlPhaseStartTest "802375 BIND cannot be shutdown correctly, if psearch is enabled and LDAP connect fails"

	rlAssertGrep "psearch yes" "/etc/named.conf"
	rlRun "service named status"
        rlRun "cp /etc/named.conf /root/"
        rlRun "sed -i 's/ldapi:\/\/\%2fvar\%2frun\%2fslapd-TESTRELM-COM.socket/ldapi:\/\/127.0.0.1/g' /etc/named.conf"
	rlRun "service named restart"
	rlRun "rndc stop"

	rlRun "service named status" 3 "Verifying that named is not running"

        rlRun "mv -f /root/named.conf /etc/"
        rlRun "service named restart"

    rlPhaseEnd
}

bz805430()
{
	# Test for bug https://bugzilla.redhat.com/show_bug.cgi?id=805430
	rlPhaseStartTest "805430 IPA dnszone-add does not accept the utmost valid serial number."

		kdestroy
		rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
		outfile="/dev/shm/utmosr-zone-addtest.txt"
		ipa dnszone-add --name-server=$MASTER --serial=4294123199 --admin-email=admin@$DOMAIN maxtzone &> $outfile
		ipa dnszone-del maxtzone
		rlRun "ipa dnszone-add --name-server=$MASTER --serial=4294123199 --admin-email=admin@$DOMAIN maxtzone" 0 "test to make sure the maxtzone dnszone-add returns 0"
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
		rlRun "ipa dnszone-mod --help | grep 'forwarder=STR' | grep per-zone\ forwarders" 0 "Ensure new string does not exist in help section"
		rlRun "ipa dnsconfig-mod --help | grep 'forwarder=STR' | grep global\ forwarders" 1 "Ensure old string does not exist in help section"
		rlRun "ipa dnsconfig-mod --help | grep 'forwarder=STR' | grep per-zone\ forwarders" 0 "Ensure new string does not exist in help section"

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

dnsbugcleanup()
{
   	rlPhaseStartTest "dns bug cleanup"
		rlRun "ipa dnszone-del $zone" 0 "Delete test zone: $zone"
	rlPhaseEnd
}

