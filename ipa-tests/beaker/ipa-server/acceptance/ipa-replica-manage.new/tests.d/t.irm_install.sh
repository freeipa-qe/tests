function irm_uninstall()
{
    MYMASTER=$(ipa-replica-manage -p $ADMINPW list $(hostname)|head -1|cut -f1 -d:)
    ipa-replica-manage -p $ADMINPW del -H $MYMASTER $(hostname) --force

    ipa_quick_uninstall
}

function irm_install()
{
    ipa_install_replica $1
}
