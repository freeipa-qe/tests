# Include rhts environment
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /opt/rhqa_ipa/ipa-server-shared.sh
. /opt/rhqa_ipa/env.sh
# AD libs
. ./adlib.sh
########################################################################
# Test Suite Globals
. ./Config
########################################################################

RELM=`echo $RELM | tr "[a-z]" "[A-Z]"`
########################################################################

######################
#     Variables      #
######################
ipainstall=`which ipa-server-install`
dmpaswd="Secret123"
named_conf="/etc/named.conf"
named_conf_bkp="/etc/named.conf.adtrust"
krb5_conf="/etc/krb5.conf"
krb5_conf_bkp="/etc/krb5.conf.bkp"
IPAhost=`hostname`
IPAhostIP=`ip addr | egrep 'inet ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAhostIP6=`ip addr | egrep 'inet6 ' | grep "global" | cut -f1 -d/ | awk '{print $NF}'`
IPAdomain="testrelm.com"
IPARealm="TESTRELM.COM"
srv_name=`hostname -s`
NBname="TESTRELM"
NBname2="TESTRELM2"
dotname1=".TESTRELM"
dotname2="TESTRELM."
dotname3="TEST.RELM"
hypname1="-TESTRELM"
hypname2="TESTRELM-"
hypname3="TEST-RELM"
lwnbnm="testrelm"
spchnm='Te!5@relm'
TID="10999"
STID="332233991"
fakeIP="10.25.11.21"
invalid_V6IP="3632:51:0:c41c:7054:ff:ae3c:c981"
smbfile="/etc/samba/smb.conf"
group1="editors"
group2="tgroup"
ipacmd=`which ipa`
sidgen_ldif="/usr/share/ipa/ipa-sidgen-task-run.ldif"
newsuffix='dc=testrelm,dc=com'
DS_binddn="CN=Directory Manager"
DMpswd="Secret123"
samba_cc="/var/run/samba/krb5cc_samba"
abrt_econf="/etc/libreport/events.d/abrt_event.conf"
ADnetbios="ADLAB"

bz_867442() {

rlPhaseStartTest "Adtrust install with AD  netbios name"
        rlRun "NBAD_Exp" 0 "Creating expect script"
        rlRun "$exp $expfile netbios-name $ADnetbios $ADdomain $ADadmin $ADpswd" 2 "Giving AD Netbios name fails as expected"
        
rlPhaseEnd

}
