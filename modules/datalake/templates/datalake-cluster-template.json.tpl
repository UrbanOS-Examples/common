{
  "general": {
    "name": "",
    "credentialName": "${CREDENTIAL_NAME}"
  },
  "placement": {
    "availabilityZone": "${CLUSTER_AZ}",
    "region": "${CLUSTER_REGION}"
  },
  "parameters": {},
  "inputs": {},
  "customDomain": {
    "clusterNameAsSubdomain": false,
    "hostgroupNameAsHostname": false
  },
  "tags": {
    "userDefinedTags": {}
  },
  "instanceGroups": [
    {
      "nodeCount": 1,
      "group": "management",
      "type": "GATEWAY",
      "parameters": {},
      "template": {
        "volumeCount": 1,
        "volumeSize": 100,
        "rootVolumeSize": 50,
        "parameters": {
          "encrypted": false
        },
        "volumeType": "standard",
        "instanceType": "${MGMT_GROUP_INSTANCE_TYPE}"
      },
      "securityGroup": {
        "securityGroupId": "${MASTER_NODES_SG}",
        "securityRules": []
      },
      "recipeNames": [],
      "recoveryMode": "MANUAL"
    },
    {
      "nodeCount": 1,
      "group": "master_namenode2",
      "type": "CORE",
      "parameters": {},
      "template": {
        "volumeCount": 1,
        "volumeSize": 100,
        "rootVolumeSize": 50,
        "parameters": {
          "encrypted": false
        },
        "volumeType": "standard",
        "instanceType": "${MASTER_GROUP_INSTANCE_TYPE}"
      },
      "securityGroup": {
        "securityGroupId": "${MASTER_NODES_SG}",
        "securityRules": []
      },
      "recipeNames": [],
      "recoveryMode": "MANUAL"
    },
    {
      "nodeCount": 1,
      "group": "master_namenode1",
      "type": "CORE",
      "parameters": {},
      "template": {
        "volumeCount": 1,
        "volumeSize": 100,
        "rootVolumeSize": 50,
        "parameters": {
          "encrypted": false
        },
        "volumeType": "standard",
        "instanceType": "${MASTER_GROUP_INSTANCE_TYPE}"
      },
      "securityGroup": {
        "securityGroupId": "${MASTER_NODES_SG}",
        "securityRules": []
      },
      "recipeNames": [],
      "recoveryMode": "MANUAL"
    },
    {
      "nodeCount": ${BROKER_NODE_COUNT},
      "group": "broker",
      "type": "CORE",
      "parameters": {},
      "template": {
        "volumeCount": 1,
        "volumeSize": 100,
        "rootVolumeSize": 50,
        "parameters": {
          "encrypted": false
        },
        "volumeType": "gp2",
        "instanceType": "${BROKER_GROUP_INSTANCE_TYPE}"
      },
      "securityGroup": {
        "securityGroupId": "${WORKER_NODES_SG}",
        "securityRules": []
      },
      "recipeNames": [],
      "recoveryMode": "MANUAL"
    },
    {
      "nodeCount": ${WORKER_NODE_COUNT},
      "group": "worker",
      "type": "CORE",
      "parameters": {},
      "template": {
        "volumeCount": 1,
        "volumeSize": 100,
        "rootVolumeSize": 50,
        "parameters": {
          "encrypted": false
        },
        "volumeType": "standard",
        "instanceType": "${WORKER_GROUP_INSTANCE_TYPE}"
      },
      "securityGroup": {
        "securityGroupId": "${WORKER_NODES_SG}",
        "securityRules": []
      },
      "recipeNames": [],
      "recoveryMode": "MANUAL"
    }
  ],
  "stackAuthentication": {
    "publicKeyId": "${SSH_KEY}"
  },
  "network": {
    "parameters": {
      "subnetId": "${CLUSTER_SUBNET}",
      "vpcId": "${CLUSTER_VPC}"
    }
  },
  "imageSettings": {
    "imageCatalog": "cloudbreak-default",
    "imageId": "69db7e20-f3ac-4d45-6f95-39204e70ddcf"
  },
  "cluster": {
    "cloudStorage": {
      "locations": [
        {
          "value": "s3a://${BUCKET_CLOUD_STORAGE}/${CLUSTER_NAME}/apps/ranger/audit/${CLUSTER_NAME}",
          "propertyFile": "ranger-hive-audit",
          "propertyName": "xasecure.audit.destination.hdfs.dir"
        },
        {
          "value": "s3a://${BUCKET_CLOUD_STORAGE}/${CLUSTER_NAME}/apps/hive/warehouse",
          "propertyFile": "hive-site",
          "propertyName": "hive.metastore.warehouse.dir"
        }
      ],
      "s3": {
        "instanceProfile": "arn:aws:iam::068920858268:instance-profile/HDP_EC2_S3_DefaultRole"
      }
    }
    "emailNeeded": false,
    "rdsConfigNames": [
      "${HIVE_CONNECTION_NAME}"
    ],
    "ambari": {
      "blueprintName": "${AMBARI_BLUEPRINT_NAME}",
      "validateBlueprint" : false,
      "gateway": {
        "path": "${AMBARI_GATEWAY_PATH}",
        "topologies": [
          {
            "topologyName": "dp-proxy",
            "exposedServices": [
              "AMBARI"
            ]
          }
        ],
        "ssoProvider": "/${AMBARI_GATEWAY_PATH}/sso/api/v1/websso",
        "gatewayType": "INDIVIDUAL",
        "ssoType": "NONE"
      },
      "enableSecurity": false,
      "userName": "${AMBARI_USERNAME}",
      "password": "${AMBARI_PASSWORD}",
      "ambariStackDetails": {
        "stack": "HDP",
        "version": "3.0",
        "stackRepoId": "HDP",
        "enableGplRepo": false,
        "verify": false,
        "repositoryVersion": "3.0.0.0-1334",
        "versionDefinitionFileUrl": "http://s3.amazonaws.com/dev.hortonworks.com/HDP/centos7/3.x/BUILDS/3.0.0.0-1334/HDP-3.0.0.0-1334.xml",
        "mpacks": []
      },
      "ambariRepoDetailsJson": {
        "version": "2.7.0.0-508",
        "baseUrl": "http://s3.amazonaws.com/dev.hortonworks.com/ambari/centos7/2.x/BUILDS/2.7.0.0-508",
        "gpgKeyUrl": "http://s3.amazonaws.com/dev.hortonworks.com/ambari/centos7/2.x/BUILDS/2.7.0.0-508/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins"
      }
    }
  }
}