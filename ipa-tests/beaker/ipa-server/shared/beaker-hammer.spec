Summary: Config files to allow using beaker on hammer in mountain view
Name: bkr-hammer
Version: 1.0
Release: 1
License: GPL
#Group: Amusements/Graphics
BuildRoot: %{_tmppath}/%{name}-root
Requires: beaker-client 
BuildArch: noarch

%description
Allows the user to use the beaker serve in mountain view without interfearing with the current beaker config.

%prep

%build

%install
rm -rf $RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT/etc/beaker
mkdir -p $RPM_BUILD_ROOT/bin

echo '#!/bin/bash
BEAKER_CLIENT_CONF=/etc/beaker/hammer.config bkr "$@"' > $RPM_BUILD_ROOT/bin/bkr-hammer
echo 'HUB_URL = "http://hammer1.dsdev.sjc.redhat.com/bkr"
# Hub authentication method. Example: krbv, password, worker_key
AUTH_METHOD = "krbv"' > $RPM_BUILD_ROOT/etc/beaker/hammer.config
echo '# script to run make for doing things like running make package to submit to the beaker server in mountain view. 
BEAKER_CLIENT_CONF=/etc/beaker/hammer.config make $1 $2 $3' > $RPM_BUILD_ROOT/bin/make-hammer.bash

chmod 755 $RPM_BUILD_ROOT/bin/bkr-hammer
chmod 755 $RPM_BUILD_ROOT/etc/beaker/hammer.config
chmod 755 $RPM_BUILD_ROOT/bin/make-hammer.bash

%clean

%pre 

%post 
echo "run bkr-hammer to use this script"

%files
%defattr(-,root,root)
/bin/bkr-hammer
/bin/make-hammer.bash
/etc/beaker/hammer.config

%changelog
* Mon Feb 11 2013 Michael Gregg <mgregg@redhat.com>
- adding make-hammer.bash to allow using make with the local beaker server
* Mon May 14 2012 Michael Gregg <mgregg@redhat.com>
- Created first spec file

