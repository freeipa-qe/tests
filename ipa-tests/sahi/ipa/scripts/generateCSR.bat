
set MYHOST=%1
set PWDFILE=pwdfile.txt

:make sure certificate databases do not already exist
del cert8.db key3.db secmod.db

:SSL setup
:generate a noise file for key generation
echo "Creating noise file ....................................................."
echo "kjasero;uae8905t76V)e6v7q4wy58w4a5;7t90r798bv2[578rbvr7b90w7rbaw0 brwb7yfbz7rv6vawp9" > noise.txt

:generate a password file for cert database
echo "Creating password file...................................................."
echo "Secret123" > %PWDFILE%

:create cert db and certificates
c:\progra~1\redhat~1\certutil -d . -N -f %PWDFILE%

:get certificate subject
set certsubj="O=TESTRELM.COM"

:generate a certificate request for the host machine
c:\progra~1\redhat~1\certutil -R -s "CN=%MYHOST%,%certsubj%" -d . -a -z noise.txt -f %PWDFILE% > %MYHOST%.csr
type %MYHOST%.csr
