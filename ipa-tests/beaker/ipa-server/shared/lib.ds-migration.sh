
SetMigrationConfig()
{
   value=$1
   rc=0

   ipa config-mod --enable-migration $value
   if [ $? -ne 0 ] ;then
	rlLog "WARNING : Configuring migration mode failed: $?"
	rc=1
   else
	rlLog "Configuring migration mode successful.  Set to: $value"	
   fi

   return $rc
}

VerifyMigrationConfig()
{

  expectedvalue=$1
  rc=0
  tmpout="/tmp/config.out"

  value=`ipa config-show | grep "Enable migration mode" | cut -d ":" -f 2`
  # trim whitespace
  value=`echo $value`
  rlLog "CONFIG SHOW VALUE: $value"

  if [ "$expectedvalue" != $value ] ; then
	rlLog "ERROR : Migration mode configuration not as expected.  Expected: $expectedvalue  Got: $value"
	rc=1
  else
	rlLog "Migration mode configuration as expected: $value"
  fi

  return $rc
}

####################################################################
## sssd_migratepwd
## Usage: use sssd to migrate directory server password

sssd_migratepwd()
   {
        {
user=$1
passwd=$2
host=$3
        expect -f - <<-EOF | grep -C 77 '^login successful'
                spawn ssh -q -o StrictHostKeyChecking=no -l "$user" $host echo 'login successful'
                expect {
                        "*assword: " {
                        send -- "$passwd\r"
                                }
                       }
                expect eof
EOF

if [ $? = 0 ]; then
        rlPass "Authentication successful for $user, as expected"
        else
        rlFail "ERROR: Authentication failed for $user, expected success."
fi
        }
   }

