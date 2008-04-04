
. ./env.cfg

cfgfile=$1

set -x
printusage()
{
	echo "Start VM is used to start a VM on a remote host. That VM needs to be"
	echo "  decompressed with a existinf vmx file"
	echo "Usage:"
	echo "start-vm.ksh <cfgfile>"
	echo "example: start=vm.ksh ./cfgs/fc7.cfg"
}

if [ "$cfgfile" = "" ] || [ "$cfgfile" = "-h" ] || [ "$cfgfile" = "--help" ]; then
	printusage;
	exit;	
fi
if [ ! -f $cfgfile ]; then
	echo ""
	echo "ERROR!  ------ cfg file not found";
	echo ""
	printusage;
	exit;
fi

echo "cfg file seems to exist, running"
. $cfgfile

echo "Using:
vmname=$VMNAME 
vmxfile=$VMXFILE
vmhost=$VMHOST
tarfile=$TARFILE
taronnfs=$TARONNFS
tarballmount=$TARBALLMOUNT
vmip=$VMIP"

echo "STARTING $VMXFILE on $VMHOST"
if [ $VIRSH = 1 ]; then
	echo "starting virsh mode"
	ssh root@$VMHOST "/usr/bin/virsh -c qemu:///system start $VMXFILE" 
else
	ssh root@$VMHOST "/usr/bin/vmrun start $VMXFILE" 
fi

