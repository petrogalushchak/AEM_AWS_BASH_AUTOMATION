#!/bin/bash

while test -n "$1"; do
  case "$1" in
  --environment|-e)
    ENV=$2
    shift
    ;;
  *)
    echo "Unknown argument: $1"
    print_help
    exit
    ;;
  esac
  shift
done

function check_author_ip {
OLD_IP=$(cat /etc/hosts | grep author | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-author" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for author"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}

function check_publisher_ip {
OLD_IP=$(cat /etc/hosts | grep publisher | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-publisher$1" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for publisher"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}

function check_dispatcher_ip {
OLD_IP=$(cat /etc/hosts | grep dispatcher | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-dispatcher$1" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for dispatcher"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}


check_author_ip
if [ "$ENV" eq "dev"] then
	check_publisher_ip
	check_dispatcher_ip
else
	check_publisher_ip 1
	check_publisher_ip 2
	check_publisher_ip 3
	check_publisher_ip 4
	check_dispatcher_ip 1
	check_dispatcher_ip 2
	check_dispatcher_ip 3
	check_dispatcher_ip 4
fi
