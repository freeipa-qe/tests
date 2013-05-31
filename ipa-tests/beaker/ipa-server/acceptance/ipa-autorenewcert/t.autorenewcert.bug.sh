#!/bin/bash

. ./lib.autorenewcert.sh

Bug_Check() {
    bug_964130
}

bug_964130() {
        # Added by Steeve
rlPhaseStartSetup "ipa cert automatic renew: wrong trust argument assigned to renewed certs bz964130"
        tmpDir=`mktemp -d`
        attrib_file1="$tmpDir/before_renewal.txt"
        attrib_file2="$tmpDir/after_renewal.txt"
        currentyear=`date +%Y`
        cert_list=`certutil -L -d /var/lib/$CAINSTANCE/alias | grep "cert-pki-ca" | awk '{print $1}'`
        relm=${RELM,,}
	rlRun "echo \"xxxxxxxxxxx---$CAINSTANCE---xxxxxxxxxxxx\"" 0 "Checking CA instance is variable finds its way in this script"
        rlRun "$ipainstall --uninstall -U" 0 "Uninstalling IPA server"
        rlRun "hwclock --hctosys" 0 "Setting to current system time"
        # Install IPA 
        rlRun "ipa-server-install --setup-dns --no-forwarder -p $ADMINPW -a $ADMINPW -r $RELM -n $relm --ip-address=$MASTERIP --hostname=$MASTER -U" 0 "IPA server install with DNS"
        sleep 30
        certutil_attributes "Trust attributes before renewal" $attrib_file1
        stop_ipa_certmonger_server "Before autorenew, stop ipa, adjust system to trigger automatic cert renew"
        adjust_to_renew
        sleep 120
        start_ipa_certmonger_server "After autorenew, start ipa, expect automatic cert renew happening in background"
        sleep 120
        for cert in $cert_list
        do
          newyear=`certutil -L -d /var/lib/$CAINSTANCE/alias -n "$cert cert-pki-ca" | grep -i "Not After" | awk '{print $8}' | head -1`
          if [ "$currentyear" -lt "$newyear" ]; then
            rlPass "$cert is renewed"
          else
            rlFail "$cert is not renewed"
          fi
        done
        certutil_attributes "Trust attributes after renewal" $attrib_file2
        rlAssertNotDiffer "$attrib_file1" "$attrib_file2"
        [ $? -eq 0 ] && rlPass "Trusts attibutes are not changed after renewal"
	rm -fr $tmpDir
        rlRun "hwclock --hctosys" 0 "Re-setting to current system time"

rlPhaseEnd
}
