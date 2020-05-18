#!/bin/bash
############################################################
# this script will install the required dependancies to generate traffic for the 
# Backdoor-EC2_CCActivity_B!DNS GD finding
############################################################
#create autoscaling group
# this section is done through the console
############################################################
# get s3 bucket name to write outputs to
if [[ "$1" != "" ]]; then
    DIR="$1"
else
    echo "no s3 bucket name given to write to\n"
    exit 0
fi
#get instaceid
EC2_INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\"`"
test -n "$EC2_INSTANCE_ID" || die 'cannot obtain instance-id'
#get availability zone
EC2_AVAIL_ZONE="`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone || die \"wget availability-zone has failed: $?\"`"
test -n "$EC2_AVAIL_ZONE" || die 'cannot obtain availability-zone'
#get region
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
#start script
startTime=`date +%s`
echo "start Runtime: " $startTime >>  /home/ec2\-user/attackOutputs/\$startTime-Backdoor-EC2_CCActivity_B!DNS_$EC2_INSTANCE_ID.txt
############################################################
#send traffic to bad IP
loops=$((1 + RANDOM % 10))
for (( i=1; i<=$loops; i++ ))
do
    #dig @server name type
    #server - is the name or IP address of the name server to query. This can be an IPv4 address in dotted-decimal notation or an IPv6 address in colon-delimited notation. When the supplied server argument is a hostname, dig resolves that name before querying that name server. If no server argument is provided, dig consults /etc/resolv.conf and queries the name servers listed there. The reply from the name server that responds is displayed.
    #name - is the name of the resource record that is to be looked up.
    #type - indicates what type of query is required - ANY, A, MX, SIG, etc. type can be any valid query type. If no type argument is supplied, dig will perform a lookup for an A record.
    BADTLD=(GuardDutyC2ActivityB.com)
    BADTYPE=(ANY A MX SIG)
    sizeTLD=${#BADTLD[@]}
    sizeTYPE=${#BADTYPE[@]}
    indexTLD=$(($RANDOM % $sizeTLD))
    indexTYPE=$(($RANDOM % $sizeTYPE))
    #use bad port and a random collection of other ports
    dig ${BADTLD[$indexTLD]} ${BADTYPE[$indexTYPE]}
    echo ${BADTLD[$indexTLD]} ${BADTYPE[$indexTYPE]} >>  /home/ec2\-user/attackOutputs/\$startTime-Backdoor-EC2_CCActivity_B!DNS_$EC2_INSTANCE_ID.txt
done
############################################################
#track times that I did this activity
end=`date +%s`
echo "end Runtime: " $end >>  /home/ec2\-user/attackOutputs/\$startTime-Backdoor-EC2_CCActivity_B!DNS_$EC2_INSTANCE_ID.txt
############################################################
#move files to a3 bucket
#aws s3 cp  /home/ec2\-user/attackOutputs/\$startTime-Backdoor-EC2_CCActivity_B!DNS_$EC2_INSTANCE_ID.txt s3://$DIR
