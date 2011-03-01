
. /usr/bin/rhts-environment.sh
. /usr/share/beakerlib/beakerlib.sh
. /dev/shm/ipa-server-shared.sh
. /dev/shm/env.sh

# Include test cases files
. ./t.master.sh
. ./t.slave.sh
. ./t.tests.common.sh

######################
# test suite         #
######################
ipasample()
{
    ipasample_envsetup
    ipasample_lifetime
    pwhistory
    ipasample_envcleanup
} # ipasample

######################
# test set           #
######################
ipasample_lifetime()
{
    ipasample_lifetime_envsetup
    minlife_nolimit
    ipasample_lifetime_minlife_somelimit
    ipasample_lifetime_minlife_negative
    ipasample_lifetime_minlife_verify
    ipasample_lifetime_envcleanup
} #ipasample_lifetime

pwhistory()
{
    pwhistory_envsetup
    pwhistory_defaultvalue
    pwhistory_lowbound
    password_history_negative
    pwhistory_envcleanup
} #pwhistory

######################
# test cases         #
######################
ipasample_envsetup()
{
    rlPhaseStartSetup "ipasample_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipasample_envsetup

ipasample_envcleanup()
{
    rlPhaseStartCleanup "ipasample_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipasample_envcleanup

ipasample_lifetime_envsetup()
{
    rlPhaseStartSetup "ipasample_lifetime_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipasample_lifetime_envsetup

ipasample_lifetime_envcleanup()
{
    rlPhaseStartCleanup "ipasample_lifetime_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipasample_lifetime_envcleanup

minlife_nolimit()
{
# looped data   : minage
# non-loop data : pwusername pwinintial_password
    rlPhaseStartTest "minlife_nolimit"
        rlLog "this is to test for minimum of password history"
        for $minage_value in $minage
        do
            minlife_nolimit_logic $pwusername $pwinintial_password $minage_value
        done
    rlPhaseEnd
} #minlife_nolimit

minlife_nolimit_logic()
{
    # accept parameters: $pwusername $pwinintial_password $minage_value
    local pwusername=$1
    local pwinintial_password=$2
    local minage_value=$3
    # test logic starts

    # test logic ends
} #minlife_nolimit_logic 

ipasample_lifetime_minlife_somelimit()
{
# looped data   : 
# non-loop data : pwusername pwinitial_password
    rlPhaseStartTest "ipasample_lifetime_minlife_somelimit"
        rlLog "set password life time to 0"
        ipasample_lifetime_minlife_somelimit_logic $pwusername $pwinitial_password
    rlPhaseEnd
} #ipasample_lifetime_minlife_somelimit

ipasample_lifetime_minlife_somelimit_logic()
{
    # accept parameters: $pwusername $pwinitial_password
    local pwusername=$1
    local pwinitial_password=$2
    # test logic starts

    # test logic ends
} #ipasample_lifetime_minlife_somelimit_logic 

ipasample_lifetime_minlife_negative()
{
# looped data   : minage
# non-loop data : pwusername pwinitial_password
    rlPhaseStartTest "ipasample_lifetime_minlife_negative"
        rlLog "negative test case for minimum password life"
        for $minage_value in $minage
        do
            ipasample_lifetime_minlife_negative_logic $pwusername $pwinitial_password $minage_value
        done
    rlPhaseEnd
} #ipasample_lifetime_minlife_negative

ipasample_lifetime_minlife_negative_logic()
{
    # accept parameters: $pwusername $pwinitial_password $minage_value
    local pwusername=$1
    local pwinitial_password=$2
    local minage_value=$3
    # test logic starts

    # test logic ends
} #ipasample_lifetime_minlife_negative_logic 

ipasample_lifetime_minlife_verify()
{
# looped data   : minage
# non-loop data : pwusername pwinitial_password
    rlPhaseStartTest "ipasample_lifetime_minlife_verify"
        rlLog "verify the changes"
        for $minage_value in $minage
        do
            ipasample_lifetime_minlife_verify_logic $pwusername $pwinitial_password $minage_value
        done
    rlPhaseEnd
} #ipasample_lifetime_minlife_verify

ipasample_lifetime_minlife_verify_logic()
{
    # accept parameters: $pwusername $pwinitial_password $minage_value
    local pwusername=$1
    local pwinitial_password=$2
    local minage_value=$3
    # test logic starts

    # test logic ends
} #ipasample_lifetime_minlife_verify_logic 

pwhistory_envsetup()
{
    rlPhaseStartSetup "pwhistory_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #pwhistory_envsetup

pwhistory_envcleanup()
{
    rlPhaseStartCleanup "pwhistory_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #pwhistory_envcleanup

pwhistory_defaultvalue()
{
# looped data   : size day
# non-loop data : admin adminpassword
    rlPhaseStartTest "pwhistory_defaultvalue"
        rlLog "verifyt the default value"
        for $size_value in $size
        do
            for $day_value in $day
            do
                pwhistory_defaultvalue_logic $admin $adminpassword $size_value $day_value
            done
        done
    rlPhaseEnd
} #pwhistory_defaultvalue

pwhistory_lowbound()
{
# looped data   : size day expired
# non-loop data : 
    rlPhaseStartTest "pwhistory_lowbound"
        rlLog "check the lower bound of value range"
        for $size_value in $size
        do
            for $day_value in $day
            do
                for $expired_value in $expired
                do
                    pwhistory_lowbound_logic $size_value $day_value $expired_value
                done
            done
        done
    rlPhaseEnd
} #pwhistory_lowbound

password_history_negative()
{
# looped data   : size day expired newpw
# non-loop data : admin adminpassword
    rlPhaseStartTest "password_history_negative"
        rlLog "do negative test on history of password"
        for $size_value in $size
        do
            for $day_value in $day
            do
                for $expired_value in $expired
                do
                    for $newpw_value in $newpw
                    do
                        password_history_negative_logic $admin $adminpassword $size_value $day_value $expired_value $newpw_value
                    done
                done
            done
        done
    rlPhaseEnd
} #password_history_negative

# Main test case
run_slave_tests()
{
	rlPass "this is the master suite place holder"
	check_list
}
