function irm_uninstall()
{
    ipa_quick_uninstall
    pkidestroy -s CA -i pki-tomcat
    rm -rf /var/log/pki/pki-tomcat
    rm -rf /etc/sysconfig/pki-tomcat
    rm -rf /etc/sysconfig/pki/tomcat/pki-tomcat
    rm -rf /var/lib/pki/pki-tomcat
    rm -rf /etc/pki/pki-tomcat

    ipa_quick_remove  

# ipa-replica-manage $PWOPT del $REPLICA4 --force
# yum -y update
}

function irm_install()
{
    ipa_install_envcleanup
    MASTER="$MY_BM"
    REPLICA="$MY_BR1 $MY_BR2 $MY_BR3 $MY_BR4"
    ipa_install_set_vars

    yum -y update
    ipa_install_replica $1
}
