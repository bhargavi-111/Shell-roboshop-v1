#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="daws92s.bond"
hosted_zone_id="Z06729933IPWAGYXJUF7Z"

for instance in $@
do
    echo "Creating an instance: $instance"

    instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
    --security-groups "Security" \
	--tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
	--query 'Instances[0].InstanceId' \
    --output text
    )

    echo "$instance ID: $instance_id"
done    