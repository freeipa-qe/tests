echo "
  iptables -A INPUT -m state --state NEW -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 443 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 389 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 636 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 88 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 464 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 464 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 88 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 123 -j ACCEPT
  service iptables save
"
  iptables -A INPUT -m state --state NEW -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 443 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 389 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 636 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 88 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p tcp --dport 464 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 464 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 88 -j ACCEPT
  iptables -A INPUT -m state --state RELATED,ESTABLISHED -p udp --dport 123 -j ACCEPT

service iptables save
iptables -L

