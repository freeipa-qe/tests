MIGRATIONCFGOPTION="enable-migration"
MIGRATIONOUTPUT="Enable migration mode"

SetMigrationConfig()
{
   value=$1
   rc=0

   ipa config-mod --$MIGRATIONCFGOPTION $value
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

  ipa-config-show > $tmpout
  config=`cat $tmpout | grep \"$MIGRATIONOUTPUT\"`
  value=`echo $config | cut -d \": \" -f 2`

  if [ "$expectedvalue" != $value ] ; then
	rlLog "ERROR : Migration mode configuration not as expected.  Expected: $expectedvalue  Got: $value"
	rc=1
  else
	rlLog "Migration mode configuration as expected: $value"
  fi

  return $rc
}
