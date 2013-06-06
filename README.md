For your IPA environment if you want master, slave and client ... reserve all the machines or have them available in advance (either x86_64 or 1386 - only arches supported). [[BR]]

To get the repo for the rhts and beaker rpms ... [https://engineering.redhat.com/trac/rhat/wiki/BeakerUserGuide  Beaker User Guide] [[BR]]

If required to use the development repositories depending on where we are in the devel cycle :: [https://wiki.idm.lab.bos.redhat.com/export/idmwiki/IPA_Devel_Repos  IPA Development Repos]

## INSTALLING A MASTER
ssh as root to the new master machine!  

```
1) Set up the following repo:
[beaker-harness]
name=beaker-harness
baseurl=http://beaker.engineering.redhat.com/harness/RedHatEnterpriseLinux6/
enabled=1
gpgcheck=0

2) # yum install subversion expect beah rhts-test-env beakerlib beakerlib-redhat
3) # git clone https://github.com/freeipa/tests.git 
4) # export MASTER=`hostname`  
5) if you are intending on installing a slave and you want the replica package prepared  
    # export SLAVE=slaves.fqdn.name)
6) # cd tests/ipa-tests/beaker/ipa-server/shared/ 
7) edit env.sh and set-root-pw.exp with your info
8) # make run
  (note if you want to change the dns domain or kerberos realm names, edit /opt/rhqa_ipa/env.sh before the next step) 
9) # cd tests/ipa-tests/beaker/ipa-server/acceptance/quickinstall/
10) # make run
```

This will install master on this machine with dogtag and dns.  Feel free to dig through the scripts to see what has to be done to install!

## INSTALLING A SLAVE 
ssh as root to the new slave machine!

```
1) Set up the following repo:
[beaker-harness]
name=beaker-harness
baseurl=http://beaker.engineering.redhat.com/harness/RedHatEnterpriseLinux6/
enabled=1
gpgcheck=0

2) # yum install subversion expect beah rhts-test-env beakerlib beakerlib-redhat
3) # git clone https://github.com/freeipa/tests.git 
4) # export MASTER=masters.fqdn.name  
5) # export SLAVE=slaves.fqdn.name
6) # cd tests/ipa-tests/beaker/ipa-server/shared/ 
7) edit env.sh and set-root-pw.exp with your info
8) # make run
   ( note if you changed the dns domain or kerberos settings when installing your master, make the same changes to the /opt/rhqa_ipa/env.sh file on the slave)
9) # cd tests/ipa-tests/beaker/ipa-server/acceptance/quickinstall/
10) # make run
```

## INSTALLING A CLIENT 
ssh as root to the new client machine!

```
1) Set up the following repo:
[beaker-harness]
name=beaker-harness
baseurl=http://beaker.engineering.redhat.com/harness/RedHatEnterpriseLinux6/
enabled=1
gpgcheck=0

2) # yum install subversion expect beah rhts-test-env beakerlib beakerlib-redhat
3) # git clone https://github.com/freeipa/tests.git 
4) # export MASTER=masters.fqdn.name  
5) # export CLIENT=clients.fqdn.name
6) # cd tests/ipa-tests/beaker/ipa-server/shared/ 
7) edit env.sh and set-root-pw.exp with your info
8) # make run
  (note if you changed the dns domain or realm on the master, make the same changes on the client)
9) # cd tests/ipa-tests/beaker/ipa-server/acceptance/quickinstall/
10) # make run
```

