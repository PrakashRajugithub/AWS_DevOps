#!/bin/bash

# Define variables
REGION="ap-southeast-1"  # Specify your AWS region
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:ap-southeast-1:235494813694:targetgroup/my-target-group/4caa5f9f4af53484"  # Update with your Target Group ARN

# Get the instance ID of the current instance
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Check if the instance ID was retrieved successfully
if [ -z "$INSTANCE_ID" ]; then
  echo "Error: Unable to retrieve instance ID."
  exit 1
fi

echo "Deregistering instance $INSTANCE_ID from target group $TARGET_GROUP_ARN in region $REGION..."

# Deregister the instance from the target group
aws elbv2 deregister-targets --target-group-arn "$TARGET_GROUP_ARN" --targets Id="$INSTANCE_ID" --region "$REGION"

# Confirm deregistration
echo "Waiting for instance to be deregistered..."
aws elbv2 wait target-deregistered --target-group-arn "$TARGET_GROUP_ARN" --targets Id="$INSTANCE_ID" --region "$REGION"

if [ $? -eq 0 ]; then
  echo "Instance $INSTANCE_ID successfully deregistered from the target group."
else
  echo "Error: Failed to deregister instance $INSTANCE_ID from the target group."
  exit 1
fi