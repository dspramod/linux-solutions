#!/bin/bash

# Set Environment Variables as cron doesn't load them
export JAVA_HOME=/usr
export EC2_HOME=/usr
export EC2_BIN=/usr/bin
export PATH=$PATH:$EC2_HOME/bin
export EC2_PRIVATE_KEY=/home/ubuntu/.ec2/ec2-private-key
export EC2_CERT=/home/ubuntu/.ec2/ec2-cert
export EC2_URL=https://ec2.ap-southeast-1.amazonaws.com # Setup your availability zone here

# Get instance id of the current server instance
MY_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
# get list of locally attached volumes
VOLUMES=$(ec2-describe-volumes | grep ${MY_INSTANCE_ID} | awk '{ print $2 }')
echo "Instance-Id: $MY_INSTANCE_ID"
echo "VOLUMES-Id: $VOLUMES"

    # Create a snapshot for all locally attached volumes
    LOG_FILE=/var/log/ec2/ebs-snapshot-backup.log
    echo "********** Starting backup for instance $MY_INSTANCE_ID _____volumes are - $VOLUMES" >> $LOG_FILE
    for VOLUME in $(echo $VOLUMES); do
        echo "Backup Volume:   $VOLUME" >> $LOG_FILE
        /usr/bin/ec2-consistent-snapshot -aws-access-key-id access-key-id-here --aws-secret-access-key secret-access-key-here --description "Backup ($MY_INSTANCE_ID) $(date +'%Y-%m-%d %H:%M:%S')" --region ap-southeast-1 $VOLUME
done
echo "********** Ran backup: $(date)" >> $LOG_FILE
echo "Completed"
