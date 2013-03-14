#!/bin/sh
# 1 is for the automount entry in ipa
ipa automountlocation-add $1

# 2 is the nis domain, 3 is the nis master server, 4 is the map name
ypcat -k -d $2 -h $3 $4 > /opt/rhqa_ipa/nis-map.$4 2>&1

ipa automountmap-add $1 $4

basedn=$(ipa env basedn|tr -d '[:space:]'|cut -f2 -d:)
cat > /tmp/amap.ldif <<EOF
dn: nis-domain=testrelm.com+nis-map=$4,cn=NIS Server,cn=plugins,cn=config
objectClass: extensibleObject
nis-domain: $3
nis-map: $4
nis-base: automountmapname=$4,cn=nis,cn=automount,$basedn
nis-filter: (objectclass=*)
nis-key-format: %{automountKey}
nis-value-format: %{automountInformation}       
EOF
ldapadd -x -h $3 -D "cn=directory manager" -w secret -f /tmp/amap.ldif

IFS=$'\n'
for line in $(cat /opt/rhqa_ipa/nis-map.$4); do 
	IFS=" "
	key=$(echo "$line" | awk '{print $1}')
	info=$(echo "$line" | sed -e "s#^$key[ \t]*##")
	ipa automountkey-add nis $4 --key="$key" --info="$info"
done
