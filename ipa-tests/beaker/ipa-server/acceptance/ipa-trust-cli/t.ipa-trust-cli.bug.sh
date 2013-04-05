. ./adlib.sh
. ./Config
. ./t.ipa-trust-cli.sh

ADnetbios="ADLAB"


bz_867442() {
	rlPhaseStartTest "Adtrust install with AD netbios name" 
		rlRun "NBAD_Exp" 0 "Creating expect script" 
		rlRun "$exp $expfile netbios-name $ADnetbios $ADdomain $ADadmin $ADpswd" 2 "Giving AD Netbios name fails as expected"
		rlRun "$trust_bin --netbios-name=$NBname -a $adminpw -U" 0 "Set netbios name back"
	rlPhaseEnd
}

bz_869741() {
        rlPhaseStartTest "Re-adding an existing entry in trust"
                rlRun "Readd_Exp" 0 "Creating expect script"
                rlRun "$exp $expfile $ADdomain $ADadmin $ADpswd" 1 "Reading trust as expected"
		rlRun 'ipa help trust-add|head -11 |grep "multiple times against same domain"' 0 "Trust-add help page optimized as expected"
        rlPhaseEnd
}
 
