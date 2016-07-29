#!/bin/bash

cd /opt/aws-cli
wget --no-check-certificate https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
./awscli-bundle/install -b ~/bin/aws
./awscli-bundle/install -h

mkdir /root/.aws
cp /opt/scripts/templates/aws.config /root/.aws/config
