#!/bin/sh

# functions 
setup_repo(){
  echo "setup repo"
  IPA_REPO=$IPA_TESTS/qautil/qaconfig/ipa.repo
  SYS_REPO_DIR=/etc/yum.repos.d/
  cp -v $IPA_REPO $SYS_REPO_DIR/.
}

setup_nameserver() {
  # local variables
  RESOLV_BK=$IPA_TESTS/qautil/qaconfig/resolv.$HOSTNAME.conf
  RESOLV_QA=$IPA_TESTS/qautil/qaconfig/resolv.conf
  RESOLV_ORG=/etc/resolv.conf

  echo "setup nameserver to envserver (10.14.0.197)"
  if [ -f $RESOLV_QA ]; then
	echo "back up original resolv.conf to $RESOLV_BK"
	/bin/cp -f $RESOLV_ORG $RESOLV_BK
	echo "replace the original resolv.conf with standard qa env resolv.conf"
	/bin/cp -f $RESOLV_QA $RESOLV_ORG
  else
	echo "Can not find QA version of [$RESOLV_QA], maybe No IPA_TESTS variable setup, please check"
	echo "nothing has been changed"
  fi
  echo "setup nameserver done"
}

help(){
	echo "Usage: qa_setupenv.sh dns"
}

config_service(){
  echo "turnoff the following services"
  echo "yum-updatesd, nscd, kudzu, isdn, hplip, hidd, firstboot, cups, bluetooth"
  chkconfig --level 35 yum-updatesd off 
  chkconfig --level 35 nscd off
  chkconfig --level 35 kudzu off
  chkconfig --level 35 isdn off 
  chkconfig --level 35 hplip off
  chkconfig --level 35 hidd off
  chkconfig --level 35 firstboot off
  chkconfig --level 35 cups off
  chkconfig --level 35 bluetooth off
  echo "stop these services" 
  service yum-updatesd stop 
  service nscd stop
  service kudzu stop
  service isdn stop 
  service hplip stop
  service hidd stop
  service firstboot stop
  service cups stop
  echo "clear all cached yum info"
  rm -rfv /var/cache/yum/* 
}

config_iptables() {
echo "
  iptables -I RH-Firewall-1-INPUT 1 -m state --state NEW -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 443 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 389 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 636 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 88 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 464 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p udp --dport 464 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p udp --dport 88 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p udp --dport 123 -j ACCEPT
  service iptables save
"
  iptables -I RH-Firewall-1-INPUT 1 -m state --state NEW -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 443 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 389 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 636 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 88 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p tcp --dport 464 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p udp --dport 464 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p udp --dport 88 -j ACCEPT
  iptables -I RH-Firewall-1-INPUT 3 -m state --state RELATED,ESTABLISHED -p udp --dport 123 -j ACCEPT

  service iptables save
}

create_links(){
  if [ -e /root/qautil ]
  then
	echo ""
  else
	echo "create link for ipa-tests/trunk/ipa-tests/qautil"
	cd /root
	ln -s /root/ipa-tests/trunk/ipa-tests/qautil 
  fi
}

rhn(){
  echo "register machine with active code (for i386 only for now)"
  if [ -x /usr/bin/rhn_register ];then
	rhnreg_ks --activationkey cb17b5abf3b104d09dee6ac55c45ed0e --force 
  fi
}

## Setup Environment starts here ##
setup_nameserver
config_service
create_links
setup_repo
config_iptables
rhn

