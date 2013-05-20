##########################################
#   Variables 
#########################################
zone="newzone"
email="ipaqar.redhat.com"
serial=2010010701
refresh=303
retry=101
expire=1202
minimum=33
ttl=55
aaaa="fec0:0:a10:6000:10:16ff:fe98:193"
afsdb="green.femto.edu."
cname="m.l.k."
txt="none=1.2.3.4"
#########################################
#  sub routines
#########################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# pkey_return_check_dns
        # Check that the pkey-only option seems to function of the ipa *-find cli option
        # Required inputs are:
        # ipa_command_to_test: This is the command we are testing, (user, group, service)
        # pkey_addstringa: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobja
        # pkey_addstringb: will be used as ipa $ipa_command_to_test-add $addstring $pkeyobja
        # pkeyobja - This is the username/groupname/object to create. this object must come up in 
        #      the resuts when a find search string is run against "general-find-string".
        #      This user/object must not exist on the system
        # pkeyobjb - This is a second username/groupname/object to create. This object must also 
        #      come up in the resuts when a find search string is run against "general-find-string"
        #      This user/object must not exist on the system
        # grep_string - This is the specific string that denotes the line to look for in the 
        #      "ipa *-find --pkey-only" output
        # general_search_string - This string will be used as "ipa *-find --pkey-only $general_search_string"
        #      Searching this way must return both pkeyobja and pkeyobjb.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pkey_return_check_dns()
{
        creturn=0
        rlLog "executing ipa $ipa_command_to_test-add $pkey_addstringa $pkeyobja"
        i="ipa $ipa_command_to_test-add $pkey_addstringa $pkeyobja"
        echo "running $i"
        $i
        ipa $ipa_command_to_test-add $pkey_addstringb $pkeyobjb
        rlLog "executing ipa $ipa_command_to_test-find --pkey-only $zone $pkeyobja | grep $grep_string | grep $pkeyobja"
        rlRun "ipa $ipa_command_to_test-find --pkey-only $zone $pkeyobja | grep $grep_string | grep $pkeyobja" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
        let creturn=$creturn+$?
        rlRun "ipa $ipa_command_to_test-find --pkey-only $zone $general_search_string | grep $grep_string | grep $pkeyobja" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
        let creturn=$creturn+$?
        rlRun "ipa $ipa_command_to_test-find --pkey-only $zone $general_search_string | grep $grep_string | grep $pkeyobjb" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
        let creturn=$creturn+$?
        rlRun "ipa $ipa_command_to_test-del $pkey_delstringa $pkeyobja" 0 "deleting the first object from this test ($pkeyobja)"
        let creturn=$creturn+$?
        rlRun "ipa $ipa_command_to_test-del $pkey_delstringb $pkeyobjb" 0 "deleting the second object from this test ($pkeyobjb)"
        let creturn=$creturn+$?
        return $creturn
}

#########################################
# Test Suite
#########################################
dnspkey()
{
  dnspkeysetup
  dnspkeytests
  dnskeycleanup
}
#########################################
# Tests
#########################################
dnspkeysetup()
{

    rlPhaseStartSetup "dns pkey setup"
	rlRun "kinitAs $ADMINID $ADMINPW" 0 "Kinit as admin user"
	 rlRun "ipa dnszone-add --name-server=$MASTER. --admin-email=$email --serial=$serial --refresh=$refresh --retry=$retry --expire=$expire --minimum=$minimum --ttl=$ttl $zone" 0 "Add test zone"
    rlPhaseEnd
}

dnspkeytests()
{
    rlPhaseStartTest "ipa-dns-pkey-001: --pkey-only test of ipa dnsrecord-find a records"
		ipa_command_to_test="dnsrecord"
		rec_string="--a-rec=4.2.2.2"
		pkey_addstringa="$rec_string $zone"
		pkey_addstringb="$rec_string $zone"
		pkey_delstringa="$rec_string $zone"
		pkey_delstringb="$rec_string $zone"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='Record\ name:'
		general_search_string=ahostf
		rlRun "pkey_return_check_dns" 0 "running checks of --pkey-only of a records in ipa dnsrecord-find"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-002: --pkey-only test of ipa dnsrecord-find AAAA records"
		ipa_command_to_test="dnsrecord"
		rec_string="--aaaa-rec=$aaaa"
		pkey_addstringa="$rec_string $zone"
		pkey_addstringb="$rec_string $zone"
		pkey_delstringa="$rec_string $zone"
		pkey_delstringb="$rec_string $zone"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='Record\ name:'
		general_search_string=ahostf
		rlRun "pkey_return_check_dns" 0 "running checks of --pkey-only of AAAA records in ipa dnsrecord-find"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-003: --pkey-only test of ipa dnsrecord-find asfdb records"
		ipa_command_to_test="dnsrecord"
		rec_string="--afsdb-rec=0\ $afsdb"
		pkey_addstringa="$rec_string $zone"
		pkey_addstringb="$rec_string $zone"
		pkey_delstringa="$rec_string $zone"
		pkey_delstringb="$rec_string $zone"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='Record\ name:'
		general_search_string=ahostf
		ipa $ipa_command_to_test-add --afsdb-rec=0\ $afsdb $zone $pkeyobja
		ipa $ipa_command_to_test-add --afsdb-rec=0\ $afsdb $zone $pkeyobjb
		rlRun "pkey_return_check_dns" 0 "running checks of --pkey-only of asfdb records in ipa dnsrecord-find"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-004: --pkey-only test of ipa dnsrecord-find cname records"
		ipa_command_to_test="dnsrecord"
		rec_string="--cname-rec=$cname"
		pkey_addstringa="$rec_string $zone"
		pkey_addstringb="$rec_string $zone"
		pkey_delstringa="$rec_string $zone"
		pkey_delstringb="$rec_string $zone"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='Record\ name:'
		general_search_string=ahostf
		rlRun "pkey_return_check_dns" 0 "running checks of --pkey-only of cname records in ipa dnsrecord-find"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-005: --pkey-only test of ipa dnsrecord-find txt records"
		ipa_command_to_test="dnsrecord"
		rec_string="--txt-rec=$txt"
		pkey_addstringa="$rec_string $zone"
		pkey_addstringb="$rec_string $zone"
		pkey_delstringa="$rec_string $zone"
		pkey_delstringb="$rec_string $zone"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='Record\ name:'
		general_search_string=ahostf
		rlRun "pkey_return_check_dns" 0 "running checks of --pkey-only of txt records in ipa dnsrecord-find"
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-006: --pkey-only test of ipa dnsrecord-find _srv records"
		ipa_command_to_test="dnsrecord"
		rec_string="--srv-rec=$srva\ $srv"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='Record\ name:'
		general_search_string=ahostf
		ipa $ipa_command_to_test-add --srv-rec=0\ 100\ 389\ why.go.here.com $zone $pkeyobja
		ipa $ipa_command_to_test-add --srv-rec=0\ 100\ 389\ why.go.here.com $zone $pkeyobjb
		rlRun "ipa $ipa_command_to_test-find --pkey-only $zone $general_search_string | grep $grep_string | grep $pkeyobja" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
		rlRun "ipa $ipa_command_to_test-find --pkey-only $zone $general_search_string | grep $grep_string | grep $pkeyobjb" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
		ipa $ipa_command_to_test-del --srv-rec=0\ 100\ 389\ why.go.here.com $zone $pkeyobja
		ipa $ipa_command_to_test-del --srv-rec=0\ 100\ 389\ why.go.here.com $zone $pkeyobjb
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-007: --pkey-only test of ipa dnsrecord-find @ records"
		ipa_command_to_test="dnsrecord"
		pkeyobja="ahostf"
		pkeyobjb="ahostfb"
		grep_string='MX\ record:'
		mxa=8.7.6.5
		mxb=1.9.8.7
		ipa $ipa_command_to_test-add --mx-rec=10\ $mxa. $zone @
		ipa $ipa_command_to_test-add --mx-rec=20\ $mxb. $zone @
		rlRun "ipa $ipa_command_to_test-find --pkey-only $zone | grep Record\ name: | grep @" 0 "make sure the $ipa_command_to_test is returned when the --pkey-only option is specified"
		ipa $ipa_command_to_test-del --mx-rec=10\ $mxa. $zone @
		ipa $ipa_command_to_test-del --mx-rec=20\ $mxb. $zone @
	rlPhaseEnd

	rlPhaseStartTest "ipa-dns-pkey-008: --pkey-only negative test of ipa dnsrecord-find AAAA records"
		ipa_command_to_test="dnsrecord"
		rec_string="--aaaa-rec=$aaaa"
		pkey_addstringa="$rec_string $zone"
		pkey_delstringa="$rec_string $zone"
		pkeyobja="ahostf"
		i="ipa $ipa_command_to_test-add $pkey_addstringa $pkeyobja"
		echo "running $i"
		$i
		rlRun "ipa $ipa_command_to_test-find --pkey-only $zone $pkeyobja | grep AAAA\ record" 1 "make sure the $ipa_command_to_test does not return 'AAAA record' returned when the --pkey-only option is specified"
		rlRun "ipa $ipa_command_to_test-del $pkey_delstringa $pkeyobja" 0 "deleting the first object from this test ($pkeyobja)"
	rlPhaseEnd
}

dnskeycleanup()
{
    rlPhaseStartCleanup "dns pkey cleanup"
         rlRun "ipa dnszone-del $zone" 0 "Delete test zone"
    rlPhaseEnd

}


