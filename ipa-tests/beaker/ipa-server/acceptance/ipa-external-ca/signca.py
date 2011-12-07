import subprocess

# Generate the self-signed cert
p = subprocess.Popen(["/usr/bin/certutil",
                      "-d", "/root/ipa-ca/",
                      "-C", "-c", "secondary",
                      "-2",
                      "-1",
                      "-5",
                      "-m", "1",
                      "-v", "60",
                      "-i", "/root/ipa.csr",
                      "-o", "/root/ipa-ca/ipa.crt",
                      "-a",
                      ],
                      stdin=subprocess.PIPE,
                      stdout=subprocess.PIPE,
                      stderr=subprocess.PIPE)
# Create key usage extension
# 0 - Digital Signature
# 1 - Non-repudiation
# 5 - Cert signing key
# Is this a critical extension [y/N]? y
p.stdin.write("0\n1\n5\n9\ny\n")
# Create basic constraint extension
# Is this a CA certificate [y/N]?  y
# Enter the path length constraint, enter to skip [<0 for unlimited pat
# Is this a critical extension [y/N]? y
p.stdin.write("y\n\ny\n")
p.stdin.write("5\n6\n7\n9\nn\n")
p.wait()
