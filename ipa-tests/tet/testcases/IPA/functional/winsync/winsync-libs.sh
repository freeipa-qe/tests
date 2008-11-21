echo "including libs file winsync-libs.sh"

AD_SERVER=win2003.rhqa.net
AD_SUFFIX="OU=mmr,DC=rhqa,DC=net"
AD_ADMIT="cn=administrator,cn=users,dc=rhqa,dc=net"
AD_ADMIT_PW="redhat"
	
MMR_PW="redhat123"
MMR_HOSTS="server64.rhqa.net replica64.rhqa.net server32.rhqa.net replica32.rhqa.net"

IPA_ADMIN="cn=directory manager"
IPA_ADMIN_PW=$MMR_PW
IPA_SUFFIX="cn=users,cn=accounts,dc=rhqa,dc=net"

IPAUSER_DEFAULT_homedir="/home/"
IPAUSER_DEFAULT_password="redhat123"
IPAUSER_DEFAULT_shell="/bin/bash"

LDAPMODIFY="/usr/lib*/mozldap/ldapmodify"
LDAPSEARCH="/usr/lib*/mozldap/ldapsearch"

ad_deluser(){
	firstname=$1
	lastname=$2
        $LDAPMODIFY -h $AD_SERVER -p 389 -D $AD_ADMIT -w $AD_ADMIT_PW -a -c << _EOF_
dn: CN=$lastname $firstname,$AD_SUFFIX 
changetype: delete
_EOF_

}

ipa_deluser(){
	username=$1
	ipa-deluser $username
}

ad_moduser(){
        lastname=$1
        firstname=$2
	attr=$3
	value=$4
        echo "modify on AD uid=[$name]"
        $LDAPMODIFY -h $AD_SERVER -p 389 -D $AD_ADMIT -w $AD_ADMIT_PW -a -c << _EOF_
dn: CN=$lastname $firstname,$AD_SUFFIX
changetype: modify
replace: $attr
$attr: $value
_EOF_

}

ad_moduser_tel(){
	firstname=$1
	lastname=$2
	$LDAPMODIFY -h $AD_SERVER -p 389 -D $AD_ADMIT -w $AD_ADMIT_PW -a -c << _EOF_
dn: CN=$lastname $firstname,$AD_SUFFIX
changetype: modify
replace: telephoneNumber
telephoneNumber : 650-123-0000-$firstname
_EOF_

}

ipa_adduser(){
	homedir=$1
	firstname=$2
	lastname=$3
	password=$4
	shell=$5
	username=$6
	ipa-adduser -c GECOS -d $homedir -f $firstname -l $lastname -p $password -s $shell $username 
}

ad_adduser(){
	firstname=$1
	lastname=$2
	username=$3
	$LDAPMODIFY -h $AD_SERVER -p 389 -D $AD_ADMIT -w $AD_ADMIT_PW -a -c << _EOF_
dn: CN=$lastname $firstname,$AD_SUFFIX
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: user
cn: $lastname $firstname
sn: $lastname
givenName: $firstname
displayName: $lastname $firstname
description: automatic add by script $lastname
accountExpires: 9223372036854775807
sAMAccountName: $username
userPrincipalName: $username@rhqa.net
_EOF_

}


