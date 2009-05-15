#!/bin/sh

LDAPMODIFY=/usr/lib*/mozldap/ldapmodify
LDAPSEARCH=/usr/lib*/mozldap/ldapsearch
DN="cn=directory manager"
PW="redhat123"

SERVER="mv32a-vm.idm.lab.bos.redhat.com"
nisport="541"

echo "[1] nis plugin config"
if /usr/lib/mozldap/ldapsearch -D "$DN" -w $PW -s   sub -b "cn=config" "cn=NIS*" "dn" | grep "NIS" 1>/dev/null 2>&1
then
	echo "    entry exist"
else
	echo "    injecting..."
$LDAPMODIFY -h $SERVER -D "$DN" -w $PW -a -c <<_EOF
dn: cn=NIS Server, cn=plugins, cn=config
objectClass: top
objectClass: nsSlapdPlugin
objectClass: extensibleObject
cn: NIS Server
nsslapd-pluginPath: /usr/lib/dirsrv/plugins/nisserver-plugin.so
nsslapd-pluginInitfunc: nis_plugin_init
nsslapd-pluginType: object
nsslapd-pluginEnabled: on
nsslapd-pluginDescription: NIS Server Plugin
nsslapd-pluginVendor: redhat.com
nsslapd-pluginVersion: 0
nsslapd-pluginID: nis-plugin
nis-tcp-wrappers-name: ypserv
nsslapd-pluginarg0: $nisport
_EOF

fi

echo "    restart dirsrv"
service dirsrv restart

echo "    verify the changes"
if /usr/sbin/rpcinfo -p | grep ypserv | grep $nisport
then
	echo "    nis plugin is up and runs on port [$nisport]"
else
	echo "    something wrong, we expect to see ypserv runs on port [$nisport]"
fi

echo "[1] configuration done , please open $nisport in firewall for both tcp and udp"

###################

echo "[2] setup nis map"
$LDAMODIFY -h $SERVER -D "$DN" -w $PW -a -c <<_EOF
dn: nis-domain=idm.lab.bos.redhat.com+nis-map=users,cn=NIS Server,cn=plugins,cn=config
objectclass: extensibleObject
nis-domain: idm.lab.bos.redhat.com
nis-map: users
nis-base: ou=People, dc=example, dc=com
nis-base: ou=nisGroup, ou=nisaccounts,dc=idm,dc=lab,dc=bos,dc=redhat,dc=com
nis-filter: (objectClass=posixAccount)
nis-key-format: %{uid}
nis-value-format: %{uid}:%{userPassword-:*}:%{uidNumber}:%{gidNumber}:%{gecos:-%{cn:-Some Unnamed User}}:%{homeDirectory}:%{loginShell:-/bin/bash}
nis-disallowed-chars: :
_EOF

