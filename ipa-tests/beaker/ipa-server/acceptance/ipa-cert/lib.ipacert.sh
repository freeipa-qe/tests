######################################
# lib.ipacert.sh                     #
######################################

# test data used in ipa cert test
hostname=`hostname | xargs echo`

create_cert()
{
    local certid=$1
    local serviceName=service_$RANDOM
    local certRequestFile=$TmpDir/certreq.$RANDOM.csr
    local certPrivateKeyFile=$TmpDir/certprikey.$RANDOM.key

    KinitAsAdmin
    # step 1: create/add a host
    #        this should already done
    
    # step 2: add a test service
    rlRun "ipa service-add $serviceName/$hostname" 0 "add service: [$serviceName/$hostname]"

    # step 3: create a cert request
    rlRun "openssl req -out "

    # step 4: process cert request
   
} #create_cert

create_cert_request_file()
{
    local requestFile=$1
    local keyFile=$2
    # command to use:
    # openssl req -out example.csr -new -newkey rsa:2048 -nodes -keyout private.key
   # yi stops here: FIXME: add expect script here to create a cert request file
} #create_cert_request_file
   
