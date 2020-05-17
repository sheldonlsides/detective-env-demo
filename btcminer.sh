#!/bin/bash -x
exec > /tmp/part-001.log 2>&1

# Get Updates and Install Necessary Packages
sudo yum update -y -q && sudo yum upgrade -y -q
sudo yum install go -y -q
sudo yum install git -y -q

#Update Path
export PATH=$PATH:/usr/local/bin:/usr/sbin:/root/.local/bin
echo 'export PATH=/root/.local/bin:/usr/sbin:$PATH' >> /home/ec2-user/.profile

# install (installs in /home/ec2-user/go/bin)
go get -u github.com/alphasoc/flightsim/

# Create FlightSim Miner Cron Job
cat <<EOT > /tmp/FlightSim-Miner.sh
#!/bin/bash
/home/ec2-user/go/bin/flightsim run miner
EOT

sudo cp /tmp/FlightSim-Miner.sh /home/ec2-user/FlightSim-Miner.sh
sudo chmod 744 /home/ec2-user/FlightSim-Miner.sh
sudo chown ec2-user /home/ec2-user/FlightSim-Miner.sh

# Create Fake Bitcoin Cron Job
cat <<EOT > /tmp/bitcoin-ping.sh
!/bin/bash
wget https://104.140.201.42:9000/favicon.ico --no-check-certificate | rm favicon.* >/dev/null 2>&1
EOT

sudo cp /tmp/bitcoin-ping.sh /home/ec2-user/bitcoin-ping.sh
sudo chmod 744 /home/ec2-user/bitcoin-ping.sh
sudo chown ec2-user /home/ec2-user/bitcoin-ping.sh

echo "*/9 * * * * /home/ec2-user/FlightSim-Miner.sh > /home/ec2-user/FlightSim-Miner.log 2>&1" >> cron
echo "*/12 * * * * /home/ec2-user/bitcoin-ping.sh > /home/ec2-user/bitcoin-ping.log 2>&1" >> cron
sudo crontab -u ec2-user cron