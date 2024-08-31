#!/bin/bash

terraform output -json | jq -r '@sh "export MASTER1=\(.master1.value)\nexport NODE1=\(.node1.value)\nexport NODE2=\(.node2.value)"' > env.sh
source env.sh

JOIN_COMMAND=$(ssh -o StrictHostKeyChecking=accept-new ubuntu@$MASTER1 'kubeadm token create --print-join-command')

echo "Join Command: $JOIN_COMMAND"

ssh -o StrictHostKeyChecking=accept-new ubuntu@$NODE1 "sudo kubeadm reset -f && sudo $JOIN_COMMAND"
ssh -o StrictHostKeyChecking=accept-new ubuntu@$NODE2 "sudo kubeadm reset -f && sudo $JOIN_COMMAND"
