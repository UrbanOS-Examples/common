#!/bin/bash

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

sudo yum -y update
sudo yum install -y amazon-efs-utils

sudo mkdir -p ${mount_point}
sudo mount -t efs ${efs_file_system_dns_name}:/ ${mount_point}
