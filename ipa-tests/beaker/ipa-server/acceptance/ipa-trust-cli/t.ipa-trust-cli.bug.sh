. ./adlib.sh
. ./Config

ADnetbios="ADLAB"


bz_867442() {
	rlPhaseStartTest "Adtrust install with AD  netbios name" 
		rlRun "NBAD_Exp" 0 "Creating expect script" 
		rlRun "$exp $expfile netbios-name $ADnetbios $ADdomain $ADadmin $ADpswd" 2 "Giving AD Netbios name fails as expected"
	rlPhaseEnd
} 
