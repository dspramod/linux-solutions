#!/bin/bash

# Set Environment Variables as cron doesn't load them
export JAVA_HOME=/usr
export EC2_HOME=/home/ec2
export EC2_BIN=/hom/ec2/bin
export PATH=$PATH:$EC2_HOME/bin
export AWS_ACCESS_KEY=your key access here
export AWS_SECRET_KEY=your secret key here
export EC2_URL=https://ec2.ap-southeast-2.amazonaws.com # Setup your availability zone here

# Get instance id of the current server instance
MY_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# get list of locally attached volumes
VOLUMES=$(ec2-describe-volumes | grep ${MY_INSTANCE_ID} | awk '{ print $2 }')
echo "Instance-Id: $MY_INSTANCE_ID"
echo "VOLUMES-Id: $VOLUMES"

#    # Create a snapshot for all locally attached volumes
    LOG_FILE=/var/log/ec2/ebs-snapshot-backup.log
    echo "********** Starting backup for instance $MY_INSTANCE_ID _____volumes are - $VOLUMES" >> $LOG_FILE
    for VOLUME in $(echo $VOLUMES); do
        echo "Backup Volume:   $VOLUME" >> $LOG_FILE
        /path/to/your/ec2-consistent-snapshot -aws-access-key-id $AWS_ACCESS_KEY --aws-secret-access-key $AWS_SECRET_KEY --description "Backup ($MY_INSTANCE_ID) $(date +'%Y-%m-%d %H:%M:%S')" --region ap-southeast-2 $VOLUME
done
echo "********** Ran backup: $(date)" >> $LOG_FILE
echo "Completed"
