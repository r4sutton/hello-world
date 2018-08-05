#!/bin/bash

# Generate hosts-file with private IP's in AWS ec2

# you need to install jq and aws cli

# Vars
hosts_file="/etc/hosts"
region="eu-west-1"
profile="default"

# AWS call
described_instances=`aws --profile ${profile} --output json ec2 describe-instances --region ${region}`

#echo $described_instances

# jq
private_ips=`echo $described_instances | jq '.Reservations[] .Instances[] .PrivateIpAddress' | tr -d \"`

#echo $private_ips

hostnames=`echo $described_instances | jq '.Reservations[] .Instances[] .Tags[] | select(.Key == "Name").Value' | tr -d \"`

# Associative array
declare -a arr1
declare -a arr2

pcounter=0
for p in $private_ips
do
  arr1[$pcounter]=$p
  let pcounter=pcounter+1
done

hcounter=0
for h in $hostnames
do
  arr2[$hcounter]=$h
  let hcounter=hcounter+1
done

# Do your thing
counter=0
for i in $private_ips
do
        found=`fgrep -c "${arr2[${counter}]}" ${hosts_file}`

        if [ "$i" != "null" ]; then

          if [ $found -eq 1 ]; then
            sed -i "" "/${arr2[${counter}]}/d" ${hosts_file}
          fi
          echo -e "${arr1[${counter}]}\t\t${arr2[${counter}]}" >> ${hosts_file}

        fi

        let counter=counter+1
done
