#!/bin/sh
# date : May 04, 2008
# by   : yzhang@redhat.com
# usage: just run script without any options, it will detect the existing firewall and insert rules into firewall
#		table "RH-Firewall-1-INPUT" 
#	assume we have default firewall setup
#		meaning: 1. we have RH-Firewall-1-INPUT exist
#			 2. the ssh port 22 is opened, and below firewall rule
#		ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state RELATED,ESTABLISHED
#				but above
#		REJECT     all  --  0.0.0.0/0            0.0.0.0/0           reject-with icmp-host-prohibited 
#		


# : scripts works only when firewall is up
echo "checking the iptable status"
if `service iptables status | grep "Firewall is stopped" 1>/dev/null 2>&1 `
then
	echo "iptables stopped, please run "
	echo "service iptables start"
	echo "to start the firewall, and re-run this script"
	exit
fi

# : save the current firewall settings
echo "saving current firewall setting"
service iptables save

# : script works only when default firewall exist: RH-Firewall-1-INPUT
echo "searching for default firewall table: RH-Firewall-1-INPUT"
if `service iptables status | grep RH-Firewall-1-INPUT 1>/dev/null 2>&1 `
then
	echo "found RH-Firewall-1-INPUT, continue"
else
	echo "no default firewall Chain table RH-Firewall-1-INPUT fount, please run"
	echo "system-config-securitylevel"
	echo "to enable the default securitylevel, and re-run this script"
	exit
fi

# : start to insert rules into default table
echo "open ports for ipa server"
i=` iptables -L --line-numbers -n | grep "state NEW tcp dpt:22" | cut -d" " -f1`
echo "open ports for TCP"
for port in 80 443 389 636 88 464
do
	iptables -L --line-numbers -n | grep "state NEW tcp dpt:$port" 1>/dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo " port: $port is already opened, skip"
	else
		echo " port: $port opened"
		iptables -I RH-Firewall-1-INPUT $i -m state --state NEW -p tcp --dport $port -j ACCEPT
	fi
done

echo "open ports for UDP"
for port in 88 464 123
do
	iptables -L --line-numbers -n | grep "state NEW udp dpt:$port" 1>/dev/null 2>&1
	if [ $? -eq 0 ];then
		echo " port: $port is already opened, skip"
	else
		echo " port: $port opened"
		iptables -I RH-Firewall-1-INPUT $i -m state --state NEW -p udp --dport $port -j ACCEPT
	fi
done

# : finally, save rules
echo "saving all rules"
service iptables save
echo "Done, the new firewall rules looks below"
iptables -L --line-numbers -n
echo ""

