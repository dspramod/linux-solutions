#!/bin/bash                                                                                                                                                  
# Set Environment Variables as cron doesn't load them
export JAVA_HOME=/usr
export EC2_HOME=/home/ec2
export EC2_BIN=/hom/ec2/bin
export PATH=$PATH:$EC2_HOME/bin
export AWS_ACCESS_KEY=your access key here
export AWS_SECRET_KEY=your secret key here
export EC2_URL=https://ec2.ap-southeast-2.amazonaws.com # Setup your availability zone here

# Get instance id of the current server instance
MY_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# get list of locally attached volumes
VOLUMES=$(ec2-describe-volumes | grep ${MY_INSTANCE_ID} | awk '{ print $2 }')

echo "`date` - starting delete old ebs snapshots"

numdays=$1
dates="(`date +%Y-%m-%d`"

for i in $(seq $numdays)
do
    dates="${dates}|`date -d \"$i days ago\" +%Y-%m-%d`"
done
dates="${dates})"

latestsnap=`ec2-describe-snapshots | /bin/grep $VOLUMES | /bin/egrep -e "$dates"`
#echo $latestsnap
latestsnapno=`echo "$latestsnap" |wc -l`
#echo $latestsnaplines

if [ "$latestsnapno" -gt 2 ]
then
echo "Deleting old snapshots.."
ec2-describe-snapshots | /bin/grep $VOLUMES | /bin/egrep -v -e "$dates" | /usr/bin/cut -f2 | xargs -n1 ec2-delete-snapshot
#snaptodel=`ec2-describe-snapshots | /bin/grep $VOLUMES | /bin/egrep -v -e "$dates"`
#echo $snaptodel
else
echo "There is only 1 snapshot for this EBS volume so NOT deleting it.."
fi
