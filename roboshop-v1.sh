
#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="daws92s.bond"
hosted_zone_id="Z06729933IPWAGYXJUF7Z"

for instance in "$@"
do
    echo "Creating an instance: $instance"

    instance_id=$(aws ec2 run-instances \
        --image-id "$ami_id" \
        --instance-type "$instance_type" \
        --security-groups "Security" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
        --query 'Instances[0].InstanceId' \
        --output text
    )

    echo "$instance ID: $instance_id"

    # Wait until instance is running
    aws ec2 wait instance-running --instance-ids "$instance_id"

    if [ "$instance" != "frontend" ]; then

        IP=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PrivateIpAddress' \
            --output text
        )

        r53_record="${instance}.${domain_name}"

    else

        IP=$(aws ec2 describe-instances \
            --instance-ids "$instance_id" \
            --query 'Reservations[0].Instances[0].PublicIpAddress' \
            --output text
        )

        r53_record="${domain_name}"

    fi

    echo "IP address: $IP"
    echo "Route53 record: $r53_record"

    # Validate IP
    if [ -z "$IP" ] || [ "$IP" = "None" ]; then
        echo "ERROR: IP address is empty for $instance"
        exit 1
    fi

    # Update Route53
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$hosted_zone_id" \
        --change-batch "{
            \"Changes\": [
                {
                    \"Action\": \"UPSERT\",
                    \"ResourceRecordSet\": {
                        \"Name\": \"$r53_record\",
                        \"Type\": \"A\",
                        \"TTL\": 60,
                        \"ResourceRecords\": [
                            {\"Value\": \"$IP\"}
                        ]
                    }
                }
            ]
        }"

    echo "Updated R53 record for $instance"

done
