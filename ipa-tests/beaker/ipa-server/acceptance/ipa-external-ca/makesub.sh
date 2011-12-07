#!/bin/sh
rm -f *.db

certutil -N -d .

# Issue the top-level CA
echo -e "5\n9\nn\ny\n10\ny\n5\n6\n7\n9\nn\n" | \
certutil -S -d . \
	-n primary \
	-s "CN=Primary CA, O=testrelm" \
	-x \
	-t CTu,CTu,CTu \
	-g 2048 \
	-m 0 \
	-v 60 \
	-z /etc/group \
	-2 \
	-1 \
	-5 

echo -e "5\n9\nn\ny\n10\ny\n5\n6\n7\n9\nn\n" | \
certutil -S -d . \
        -n secondary \
	-s "CN=Secondary CA, O=testrelm" \
	-c primary \
	-t CTu,CTu,CTu \
	-m 1 \
	-v 60 \
        -z /etc/group \
	-2 \
	-1 \
	-5
