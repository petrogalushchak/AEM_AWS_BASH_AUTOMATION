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
OLD_IP=$(cat /etc/hosts | grep publisher$1 | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-publisher$1" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for publisher"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}

function check_prepublisher_ip {
OLD_IP=$(cat /etc/hosts | grep prepublisher$1 | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-prepublisher$1" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for publisher"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}

function check_dispatcher_ip {
OLD_IP=$(cat /etc/hosts | grep dispatcher$1 | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-dispatcher$1" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for dispatcher"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}

function check_predispatcher_ip {
OLD_IP=$(cat /etc/hosts | grep predispatcher$1 | awk '{print $1}')
NEW_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$ENV-predispatcher$1" | grep "PrivateIpAddress" | awk 'NR==1' | awk '{gsub(/"/, "", $2); print $2}' | sed 's/,//g')
if [ $OLD_IP != $NEW_IP ]
then
	echo "Setting new IP for dispatcher"
	sed -i -- "s/$OLD_IP/$NEW_IP/g" /etc/hosts && echo "IP set"
fi
}

function check_stage {
  check_publisher_ip 1
	check_publisher_ip 2
	check_publisher_ip 3
	check_publisher_ip 4
  check_dispatcher_ip 1
	check_dispatcher_ip 2
	check_dispatcher_ip 3
	check_dispatcher_ip 4
}

function check_prod {
  check_publisher_ip 1
	check_publisher_ip 2
	check_publisher_ip 3
	check_publisher_ip 4
	check_prepublisher_ip 1
	check_prepublisher_ip 2
  check_dispatcher_ip 1
	check_dispatcher_ip 2
	check_dispatcher_ip 3
	check_dispatcher_ip 4
  check_predispatcher_ip 1
  check_predispatcher_ip 2
}

check_author_ip

if [ "$ENV" == "dev"] then
	check_publisher_ip
	check_dispatcher_ip
fi

if [ "$ENV" == "stage"] then
  check_stage
fi

if [ "$ENV" == "prod"] then
  check_prod
fi
