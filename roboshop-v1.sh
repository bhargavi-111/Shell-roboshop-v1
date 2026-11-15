#!/bin/bash

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="daws92s.bond"
hosted_zone_id="Z06729933IPWAGYXJUF7Z"

for instance in $@
do
    echo "Creating an instance: $instance"
done    