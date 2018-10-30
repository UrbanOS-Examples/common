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
  "imageType": "prewarmed",
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
    },
    "subnetCIDR": null
  },
  "imageSettings": {
    "imageCatalog": "cloudbreak-default",
    "imageId": "086a2119-4cc2-4655-511b-0a528f7406c0"
  },
  "cluster": {
    "cloudStorage": {
      "locations": [
        {
          "value": "s3a://${BUCKET_CLOUD_STORAGE}/scos-hdp-datalake/apps/ranger/audit/scos-hdp-datalake",
          "propertyFile": "ranger-hive-audit",
          "propertyName": "xasecure.audit.destination.hdfs.dir"
        },
        {
          "value": "s3a://${BUCKET_CLOUD_STORAGE}/scos-hdp-datalake/apps/hive/warehouse",
          "propertyFile": "hive-site",
          "propertyName": "hive.metastore.warehouse.dir"
        }
      ],
      "s3": {
        "instanceProfile": "${INSTANCE_PROFILE_FOR_BUCKET_ACCESS}"
      }
    },
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
        "version": "2.6",
        "stackRepoId": "HDP",
        "enableGplRepo": false,
        "verify": false,
        "repositoryVersion": "2.6.5.0-292",
        "versionDefinitionFileUrl": "http://public-repo-1.hortonworks.com/HDP/centos6/2.x/updates/2.6.5.0/HDP-2.6.5.0-292.xml",
        "mpacks": []
      },
      "ambariRepoDetailsJson": {
        "version": "2.6.2.2",
        "baseUrl": "http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.6.2.2",
        "gpgKeyUrl": "http://public-repo-1.hortonworks.com/ambari/centos6/2.x/updates/2.6.2.2/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins"
      }
    }
  }
}