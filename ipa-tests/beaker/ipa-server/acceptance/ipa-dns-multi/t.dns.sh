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
a2="1.2.3.4,2.3.4.5"
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

dnscleanup()
{
	rlPhaseStartTest "dns acceptance cleanup"
		rlRun "ipa dnszone-del $zone" 0 "Delete the zone created for this test"
		rlRun "ipa dnszone-find $zone" 1 "Make sure the zone delete happened properly"
		rlRun "ipa dnszone-del $ptrzone" 0 "Delete the ptr zone created for this test"
		rlRun "ipa dnszone-find $ptrzone" 1 "Make sure the ptr zone delete happened properly"
	rlPhaseEnd
}
