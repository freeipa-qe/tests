#/bin/sh
echo "[search base]=>[$1]"
echo "[search filter]=>[$2]"
echo "[output options]=>[$3]"
ADMIN="CN=directory manager"
PASSWD=redhat123
LDAP_SEARCH=/usr/lib/mozldap/ldapsearch

$LDAP_SEARCH -D "$ADMIN" -w $PASSWD -s sub -b $1 $2 $3
