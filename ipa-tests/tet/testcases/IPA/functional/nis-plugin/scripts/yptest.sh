#!/bin/bash

client=$1

ssh root@$client "service portmap restart; service ypbind restart; yptest"


