
######################
# test suite         #
######################
ipakrbt()
{
    ipakrbt_envsetup
    ipakrbt_show
    ipakrbt_reset
    ipakrbt_mod
    ipakrbt_envcleanup
} # ipakrbt

######################
# test set           #
######################
ipakrbt_show()
{
    ipakrbt_show_envsetup
    ipakrbt_show_rights
    ipakrbt_show_all
    ipakrbt_show_raw
    ipakrbt_show_envcleanup
} #ipakrbt_show

ipakrbt_reset()
{
    ipakrbt_reset_envsetup
    ipakrbt_reset_default
    ipakrbt_reset_envcleanup
} #ipakrbt_reset

ipakrbt_mod()
{
    ipakrbt_mod_envsetup
    ipakrbt_mod_maxlife
    ipakrbt_mod_maxrenew
    ipakrbt_mod_setattr
    ipakrbt_mod_addattr
    ipakrbt_mod_envcleanup
} #ipakrbt_mod

######################
# test cases         #
######################
ipakrbt_envsetup()
{
    rlPhaseStartSetup "ipakrbt_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_envsetup

ipakrbt_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_envcleanup

ipakrbt_show_envsetup()
{
    rlPhaseStartSetup "ipakrbt_show_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_show_envsetup

ipakrbt_show_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_show_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_show_envcleanup

ipakrbt_show_rights()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_show_rights"
        rlLog "ipa krbtpolicy-show --rights"
        ipakrbt_show_rights_logic
    rlPhaseEnd
} #ipakrbt_show_rights

ipakrbt_show_rights_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_show_rights_logic 

ipakrbt_show_all()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_show_all"
        rlLog "ipa krbtpolicy-show --all"
        ipakrbt_show_all_logic
    rlPhaseEnd
} #ipakrbt_show_all

ipakrbt_show_all_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_show_all_logic 

ipakrbt_show_raw()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_show_raw"
        rlLog "ipa krbtpolicy-show --raw"
        ipakrbt_show_raw_logic
    rlPhaseEnd
} #ipakrbt_show_raw

ipakrbt_show_raw_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_show_raw_logic 

ipakrbt_reset_envsetup()
{
    rlPhaseStartSetup "ipakrbt_reset_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_reset_envsetup

ipakrbt_reset_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_reset_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_reset_envcleanup

ipakrbt_reset_default()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_reset_default"
        rlLog "restore krbtpolicy back to default for a given user"
        ipakrbt_reset_default_logic
    rlPhaseEnd
} #ipakrbt_reset_default

ipakrbt_reset_default_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_reset_default_logic 

ipakrbt_mod_envsetup()
{
    rlPhaseStartSetup "ipakrbt_mod_envsetup"
        #environment setup starts here

        #environment setup ends   here
    rlPhaseEnd
} #ipakrbt_mod_envsetup

ipakrbt_mod_envcleanup()
{
    rlPhaseStartCleanup "ipakrbt_mod_envcleanup"
        #environment cleanup starts here

        #environment cleanup ends   here
    rlPhaseEnd
} #ipakrbt_mod_envcleanup

ipakrbt_mod_maxlife()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxlife"
        rlLog "set the maxlife of kerberos ticket"
        ipakrbt_mod_maxlife_logic
    rlPhaseEnd
} #ipakrbt_mod_maxlife

ipakrbt_mod_maxlife_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_mod_maxlife_logic 

ipakrbt_mod_maxrenew()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_maxrenew"
        rlLog "set max renew life of kerberos ticket"
        ipakrbt_mod_maxrenew_logic
    rlPhaseEnd
} #ipakrbt_mod_maxrenew

ipakrbt_mod_maxrenew_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_mod_maxrenew_logic 

ipakrbt_mod_setattr()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_setattr"
        rlLog "setattr"
        ipakrbt_mod_setattr_logic
    rlPhaseEnd
} #ipakrbt_mod_setattr

ipakrbt_mod_setattr_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_mod_setattr_logic 

ipakrbt_mod_addattr()
{
# looped data   : 
# non-loop data : 
    rlPhaseStartTest "ipakrbt_mod_addattr"
        rlLog "addattr"
        ipakrbt_mod_addattr_logic
    rlPhaseEnd
} #ipakrbt_mod_addattr

ipakrbt_mod_addattr_logic()
{
    # accept parameters: NONE
    # test logic starts
        rlFail "EMPTY LOGIC"
    # test logic ends
} # ipakrbt_mod_addattr_logic 
