
# main test function 
ipasample()
{
# Test Sets: 2
   ipasample_lifetime
   pwhistory
} # ipasample

# testset
ipasample_lifetime()
{
   minlife_nolimit
   ipasample_lifetime_minlife_somelimit
   ipasample_lifetime_minlife_negative
   ipasample_lifetime_minlife_verify
} #ipasample_lifetime

pwhistory()
{
   pwhistory_evnsetup
   pwhistory_defaultvalue
   pwhistory_lowbound
   password_history_negative
   pwhistory_envcleanup
} #pwhistory

# test cases
minlife_nolimit()
{
# loop   : minage
# no loop: pwusername pwinintial_password

   rlPhaseStartTest "this is to test for minimum of password history"
        for $minage_value in $minage
        do
            minlife_nolimit_logic $pwusername $pwinintial_password $minage_value
        done
   rlPhaseEnd

} #minlife_nolimit

ipasample_lifetime_minlife_somelimit()
{
# loop   : 
# no loop: pwusername pwinitial_password

   rlPhaseStartTest "set password life time to 0"
        ipasample_lifetime_minlife_somelimit_logic $pwusername $pwinitial_password
   rlPhaseEnd

} #ipasample_lifetime_minlife_somelimit

ipasample_lifetime_minlife_negative()
{
# loop   : minage
# no loop: pwusername pwinitial_password

   rlPhaseStartTest "negative test case for minimum password life"
        for $minage_value in $minage
        do
            ipasample_lifetime_minlife_negative_logic $pwusername $pwinitial_password $minage_value
        done
   rlPhaseEnd

} #ipasample_lifetime_minlife_negative

ipasample_lifetime_minlife_verify()
{
# loop   : minage
# no loop: pwusername pwinitial_password

   rlPhaseStartTest "verify the changes"
        for $minage_value in $minage
        do
            ipasample_lifetime_minlife_verify_logic $pwusername $pwinitial_password $minage_value
        done
   rlPhaseEnd

} #ipasample_lifetime_minlife_verify

pwhistory_evnsetup()
{
# loop   : historysize
# no loop: admin adminpassword

   rlPhaseStartTest "set up the environment for password history test"
        for $historysize_value in $historysize
        do
            pwhistory_evnsetup_logic $admin $adminpassword $historysize_value
        done
   rlPhaseEnd

} #pwhistory_evnsetup

pwhistory_defaultvalue()
{
# loop   : size day
# no loop: admin adminpassword

   rlPhaseStartTest "verifyt the default value"
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
# loop   : size day expired
# no loop: 

   rlPhaseStartTest "check the lower bound of value range"
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
# loop   : size day expired newpw
# no loop: admin adminpassword

   rlPhaseStartTest "do negative test on history of password"
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

pwhistory_envcleanup()
{
# loop   : size day expired newpw junkpw
# no loop: admin adminpassword

   rlPhaseStartTest "clean up environment setting, back to default"
        for $size_value in $size
        do
            for $day_value in $day
            do
                for $expired_value in $expired
                do
                    for $newpw_value in $newpw
                    do
                        for $junkpw_value in $junkpw
                        do
                            pwhistory_envcleanup_logic $admin $adminpassword $size_value $day_value $expired_value $newpw_value $junkpw_value
                        done
                    done
                done
            done
        done
   rlPhaseEnd

} #pwhistory_envcleanup

minlife_nolimit_logic()
{
   # accept parameters:
   # $pwusername $pwinintial_password $minage
   $pwusername=$1
   $pwinintial_password=$2
   $minage=$3

   # test logic starts

   # test logic ends
} #minlife_nolimit_logic 

ipasample_lifetime_minlife_somelimit_logic()
{
   # accept parameters:
   # $pwusername $pwinitial_password
   $pwusername=$1
   $pwinitial_password=$2

   # test logic starts

   # test logic ends
} #ipasample_lifetime_minlife_somelimit_logic 

ipasample_lifetime_minlife_negative_logic()
{
   # accept parameters:
   # $pwusername $pwinitial_password $minage
   $pwusername=$1
   $pwinitial_password=$2
   $minage=$3

   # test logic starts

   # test logic ends
} #ipasample_lifetime_minlife_negative_logic 

ipasample_lifetime_minlife_verify_logic()
{
   # accept parameters:
   # $pwusername $pwinitial_password $minage
   $pwusername=$1
   $pwinitial_password=$2
   $minage=$3

   # test logic starts

   # test logic ends
} #ipasample_lifetime_minlife_verify_logic 

pwhistory_evnsetup_logic()
{
   # accept parameters:
   # $admin $adminpassword $historysize
   $admin=$1
   $adminpassword=$2
   $historysize=$3

   # test logic starts

   # test logic ends
} #pwhistory_evnsetup_logic 

pwhistory_defaultvalue_logic()
{
   # accept parameters:
   # $admin $adminpassword $size_value $day
   $admin=$1
   $adminpassword=$2
   $size_value=$3
   $day=$4

   # test logic starts

   # test logic ends
} #pwhistory_defaultvalue_logic 

pwhistory_lowbound_logic()
{
   # accept parameters:
   # $size_value $day_value $expired
   $size_value=$1
   $day_value=$2
   $expired=$3

   # test logic starts

   # test logic ends
} #pwhistory_lowbound_logic 

password_history_negative_logic()
{
   # accept parameters:
   # $admin $adminpassword $size_value $day_value $expired_value $newpw
   $admin=$1
   $adminpassword=$2
   $size_value=$3
   $day_value=$4
   $expired_value=$5
   $newpw=$6

   # test logic starts

   # test logic ends
} #password_history_negative_logic 

pwhistory_envcleanup_logic()
{
   # accept parameters:
   # $admin $adminpassword $size_value $day_value $expired_value $newpw_value $junkpw
   $admin=$1
   $adminpassword=$2
   $size_value=$3
   $day_value=$4
   $expired_value=$5
   $newpw_value=$6
   $junkpw=$7

   # test logic starts

   # test logic ends
} #pwhistory_envcleanup_logic 
