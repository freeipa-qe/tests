readme.txt by yzhang@redhat.com 2013.1.16


Testing cert automatic renew cost me a great time. When all test cases are now passed, it worth to write something so I can learn from it.

1.
 test design
(1) Not all certs are expire at same time. There is no coordination of when a certain certs will expire – as well as when to renew. And for the automatic renewal, it is also kind of random. Although certmonger start to try cert renewal 28 days before it expires, there is are some flexibility there. Certmonger will try at 28days , if it failed to renew it (certmonger will carefully check the pki-ca instance, if it is so busy, it will report failure and try later), it will retry at 14th days, then 7th days... till 1 hour or even 30 minutes before the certs is actually expires. The result is each time the test script gets run, the inter-steps could be different. For this reason, there is a step to list out current status of all certs, 

(2) Cert is always relate to date. In order to verify cert, we need change system date. This is the test approach used in this test suite. Many people, well, developers, don't really like this idea as they are afraid there are side effects that could cause IPA server to fail. With this doubt in mind, I am afraid to discuss failures with developers. The result is that I spend tremendous time to repeat my test and tried all I could to unearth the root cause of test case failures. And a great amount of my time being wasted. What I can confirm is that : there is nothing wrong with this approach. It is ok to change system date and monitor what server would behave. I haven't seen a single side effect. 

2. improvements: 
(1) in-tween ipa start and ipa stop, “sleep <20 minutes>” used so certmonger has chance to renew certs. Although this works ok, this is not a reliable way to do so. We should have statement to monitor /var/log/message , grep for certmonger renewal message – something like “generated and saved”
(2) When certs are renewed, the renewed certs are two place: cert db or ldap server. Server certs are in their cert db like  /etc/httpd/alias/ /etc/dirsrv/slapd-<inst name> ... we need double check. These certs should be 'pre-valid' status

3. utils: 

[root@apple (RH6.4-i386) ipa-autorenewcert] ./list.all.current.ipa.certs.sh 
[sort_certs ] sorted by cert timeLeft_sec: 
       [caSSLServiceCert oscpSubsystemCert caSubsystemCert caAuditLogCert ipaAgentCert ipaServiceCert_ds ipaServiceCert_pki ipaServiceCert_httpd ]

+-------------- all IPA certs (round ) Days left to the CA Cert life limit [8 Year 1 Day(s) 23 h 59 m 58 s] ----------------------------+
===== Summary: are all certs valid? [yes] current system date [Wed Jan 16 15:12:36 PST 2013], ===
[valid certs]:
caSSLServiceCert     (Server-Cert cert-pki-ca)      #3 : [Mon Jan 14 12:22:08 PST 2013]~~[Sun Jan  4 12:22:08 PST 2015] expires@(717 D 21 h 9 m 31 s ) life [720 D 0 s] 
oscpSubsystemCert    (ocspSigningCert cert-pki-ca)  #2 : [Mon Jan 14 12:22:08 PST 2013]~~[Sun Jan  4 12:22:08 PST 2015] expires@(717 D 21 h 9 m 30 s ) life [720 D 0 s] 
caSubsystemCert      (subsystemCert cert-pki-ca)    #4 : [Mon Jan 14 12:22:09 PST 2013]~~[Sun Jan  4 12:22:09 PST 2015] expires@(717 D 21 h 9 m 29 s ) life [720 D 0 s] 
caAuditLogCert       (auditSigningCert cert-pki-ca) #5 : [Mon Jan 14 12:22:10 PST 2013]~~[Sun Jan  4 12:22:10 PST 2015] expires@(717 D 21 h 9 m 29 s ) life [720 D 0 s] 
ipaAgentCert         (ipaCert)                      #7 : [Mon Jan 14 12:23:01 PST 2013]~~[Sun Jan  4 12:23:01 PST 2015] expires@(717 D 21 h 10 m 19 s) life [720 D 0 s] 
ipaServiceCert_ds    (Server-Cert)                  #8 : [Mon Jan 14 12:23:26 PST 2013]~~[Thu Jan 15 12:23:26 PST 2015] expires@(728 D 21 h 10 m 42 s) life [731 D 0 s] 
ipaServiceCert_pki   (Server-Cert)                  #9 : [Mon Jan 14 12:24:24 PST 2013]~~[Thu Jan 15 12:24:24 PST 2015] expires@(728 D 21 h 11 m 39 s) life [731 D 0 s] 
ipaServiceCert_httpd (Server-Cert)                  #10: [Mon Jan 14 12:26:22 PST 2013]~~[Thu Jan 15 12:26:22 PST 2015] expires@(728 D 21 h 13 m 36 s) life [731 D 0 s] 

[expired certs]:
+--------------------------------------------------------------------------------------------------+

