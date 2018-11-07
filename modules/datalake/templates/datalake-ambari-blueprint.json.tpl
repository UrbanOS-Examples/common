{
    "Blueprints": {
        "blueprint_name": "smartcolumbusos-datalake-hdp26",
        "stack_name": "HDP",
        "stack_version": "2.6"
    },
    "settings": [
        {
            "recovery_settings": []
        },
        {
            "service_settings": [
                {
                    "name": "HIVE",
                    "credential_store_enabled": "false"
                }
            ]
        },
        {
            "component_settings": []
        }
    ],
    "configurations": [
        {
            "core-site": {
                "properties": {
                    "fs.defaultFS": "hdfs://cluster",
                    "fs.trash.interval": "4320",
                    "hadoop.proxyuser.yarn.hosts": "%HOSTGROUP::master_namenode1%,%HOSTGROUP::master_namenode2%",
                    "hadoop.proxyuser.hive.hosts": "%HOSTGROUP::master_namenode1%,%HOSTGROUP::master_namenode2%",
                    "ha.zookeeper.quorum": "%HOSTGROUP::broker%:2181"
                }
            }
        },
        {
            "hdfs-site": {
                "properties": {
                    "dfs.namenode.safemode.threshold-pct": "0.99",
                    "dfs.client.failover.proxy.provider.cluster": "org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider",
                    "dfs.ha.automatic-failover.enabled": "true",
                    "dfs.ha.fencing.methods": "shell(/bin/true)",
                    "dfs.ha.namenodes.cluster": "namenode1,namenode2",
                    "dfs.namenode.http-address": "%HOSTGROUP::master_namenode1%:50070",
                    "dfs.namenode.http-address.cluster.namenode1": "%HOSTGROUP::master_namenode1%:50070",
                    "dfs.namenode.http-address.cluster.namenode2": "%HOSTGROUP::master_namenode2%:50070",
                    "dfs.namenode.https-address": "%HOSTGROUP::master_namenode1%:50470",
                    "dfs.namenode.https-address.cluster.namenode1": "%HOSTGROUP::master_namenode1%:50470",
                    "dfs.namenode.https-address.cluster.namenode2": "%HOSTGROUP::master_namenode2%:50470",
                    "dfs.namenode.rpc-address.cluster.namenode1": "%HOSTGROUP::master_namenode1%:8020",
                    "dfs.namenode.rpc-address.cluster.namenode2": "%HOSTGROUP::master_namenode2%:8020",
                    "dfs.namenode.shared.edits.dir": "qjournal://%HOSTGROUP::master_namenode1%:8485;%HOSTGROUP::master_namenode2%:8485;%HOSTGROUP::management%:8485/cluster",
                    "dfs.nameservices": "cluster"
                }
            }
        },
        {
            "hive-site": {
                "properties": {
                    "hive.metastore.uris": "thrift://%HOSTGROUP::master_namenode1%:9083,thrift://%HOSTGROUP::master_namenode2%:9083",
                    "hive.metastore.warehouse.dir": "s3a://${CLOUD_STORAGE_BUCKET}/scos-hdp-datalake/apps/hive/warehouse",
                    "hive.exec.compress.output": "true",
                    "hive.merge.mapfiles": "true",
                    "hive.server2.tez.initialize.default.sessions": "false",
                    "hive.server2.transport.mode": "http",
                    "hive.prewarm.enabled": "true",
                    "javax.jdo.option.ConnectionURL": "{{{ rds.hive.connectionURL }}}",
                    "javax.jdo.option.ConnectionDriverName": "{{{ rds.hive.connectionDriver }}}",
                    "javax.jdo.option.ConnectionUserName": "{{{ rds.hive.connectionUserName }}}",
                    "javax.jdo.option.ConnectionPassword": "{{{ rds.hive.connectionPassword }}}"
                }
            }
        },
        {
            "hive-env": {
                "properties" : {
                    "hive_database" : "Existing {{{ rds.hive.subprotocol }}} Database",
                    "hive_database_type" : "{{{ rds.hive.databaseEngine }}}",
                    "hive_security_authorization": "Ranger"
                }
            }
        },
        {
            "hive-interactive-site": {
                "properties": {
                    "hive.prewarm.enabled": "true"
                }
            }
        },
        {
            "mapred-site": {
                "properties": {
                    "mapreduce.job.reduce.slowstart.completedmaps": "0.7",
                    "mapreduce.map.output.compress": "true",
                    "mapreduce.output.fileoutputformat.compress": "true"
                }
            }
        },
        {
            "tez-site": {
                "properties": {
                    "tez.runtime.shuffle.parallel.copies": "4",
                    "tez.runtime.enable.final-merge.in.output": "false",
                    "tez.am.am-rm.heartbeat.interval-ms.max": "2000"
                }
            }
        },
        {
            "yarn-site": {
                "properties": {
                    "hadoop.registry.rm.enabled": "true",
                    "hadoop.registry.zk.quorum": "%HOSTGROUP::master_namenode1%:2181,%HOSTGROUP::master_namenode2%:2181,%HOSTGROUP::management%:2181",
                    "yarn.acl.enable": "true",
                    "yarn.log.server.url": "http://%HOSTGROUP::master_namenode2%:19888/jobhistory/logs",
                    "yarn.resourcemanager.address": "%HOSTGROUP::master_namenode1%:8050",
                    "yarn.resourcemanager.admin.address": "%HOSTGROUP::master_namenode1%:8141",
                    "yarn.resourcemanager.cluster-id": "yarn-cluster",
                    "yarn.resourcemanager.ha.automatic-failover.zk-base-path": "/yarn-leader-election",
                    "yarn.resourcemanager.ha.enabled": "true",
                    "yarn.resourcemanager.ha.rm-ids": "rm1,rm2",
                    "yarn.resourcemanager.hostname": "%HOSTGROUP::master_namenode1%",
                    "yarn.resourcemanager.hostname.rm1": "%HOSTGROUP::master_namenode1%",
                    "yarn.resourcemanager.hostname.rm2": "%HOSTGROUP::master_namenode2%",
                    "yarn.resourcemanager.recovery.enabled": "true",
                    "yarn.resourcemanager.resource-tracker.address": "%HOSTGROUP::master_namenode1%:8025",
                    "yarn.resourcemanager.scheduler.address": "%HOSTGROUP::master_namenode1%:8030",
                    "yarn.resourcemanager.store.class": "org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore",
                    "yarn.resourcemanager.webapp.address": "%HOSTGROUP::master_namenode1%:8088",
                    "yarn.resourcemanager.webapp.address.rm1": "%HOSTGROUP::master_namenode1%:8088",
                    "yarn.resourcemanager.webapp.address.rm2": "%HOSTGROUP::master_namenode2%:8088",
                    "yarn.resourcemanager.webapp.https.address": "%HOSTGROUP::master_namenode1%:8090",
                    "yarn.resourcemanager.webapp.https.address.rm1": "%HOSTGROUP::master_namenode1%:8090",
                    "yarn.resourcemanager.webapp.https.address.rm2": "%HOSTGROUP::master_namenode2%:8090"
                }
            }
        },
        {
            "ranger-hive-audit": {
                "properties": {
                    "xasecure.audit.destination.hdfs.dir": "s3a://${CLOUD_STORAGE_BUCKET}/scos-hdp-datalake/apps/ranger/audit/scos-hdp-datalake"
                }
            }
        },
        {
            "ranger-admin-site": {
                "properties": {
                    "ranger.ldap.user.searchfilter": "(uid={0})",
                    "ranger.ldap.group.searchfilter": "(cn={0})"
                }
            }
        },
        {
            "ranger-env": {
                "properties": {
                    "ranger-hdfs-plugin-enabled" : "Yes",
                    "ranger-knox-plugin-enabled" : "Yes",
                    "ranger-hive-plugin-enabled" : "Yes",
                    "ranger-yarn-plugin-enabled" : "Yes",
                    "ranger_admin_password": "${AMBARI_PASSWORD}",
                    "admin_password": "${AMBARI_PASSWORD}",
                    "ranger_privelege_user_jdbc_url": "jdbc:postgresql://${RANGER_DB_ENDPOINT}",
                    "create_db_dbuser": "false"
                }
            }
        },
        {
            "capacity-scheduler": {
                "properties": {
                    "yarn.scheduler.capacity.root.queues": "default,llap",
                    "yarn.scheduler.capacity.root.capacity": "100",
                    "yarn.scheduler.capacity.root.default.capacity": "10",
                    "yarn.scheduler.capacity.root.default.maximum-capacity": "100",
                    "yarn.scheduler.capacity.root.llap.maximum-capacity": "100",
                    "yarn.scheduler.capacity.root.llap.capacity": "90"
                }
            }
        }
    ],
    "host_groups": [
        {
            "name": "management",
            "configurations": [],
            "components": [
                {"name": "METRICS_COLLECTOR"},
                {"name": "METRICS_MONITOR"},
                {"name": "METRICS_GRAFANA"},
                {"name": "JOURNALNODE"},
                {"name": "INFRA_SOLR"},
                {"name": "INFRA_SOLR_CLIENT"},
                {"name": "ZOOKEEPER_CLIENT"},
                {"name": "HDFS_CLIENT"},
                {"name": "YARN_CLIENT"},
                {"name": "MAPREDUCE2_CLIENT"},
                {"name": "HIVE_CLIENT"},
                {"name": "TEZ_CLIENT"},
                {"name": "RANGER_TAGSYNC"},
                {"name": "RANGER_USERSYNC"},
                {"name": "RANGER_ADMIN"},
                {"name": "KNOX_GATEWAY"}
            ],
            "cardinality": "1"
        },
        {
            "name": "master_namenode1",
            "configurations": [],
            "components": [
                {"name": "NAMENODE"},
                {"name": "ZKFC"},
                {"name": "RESOURCEMANAGER"},
                {"name": "METRICS_MONITOR"},
                {"name": "APP_TIMELINE_SERVER"},
                {"name": "HIVE_METASTORE"},
                {"name": "HIVE_SERVER"},
                {"name": "JOURNALNODE"},
                {"name": "HIVE_CLIENT"},
                {"name": "HDFS_CLIENT"},
                {"name": "YARN_CLIENT"},
                {"name": "ZOOKEEPER_CLIENT"},
                {"name": "SPARK2_CLIENT"},
                {"name": "MAPREDUCE2_CLIENT"},
                {"name": "TEZ_CLIENT"}
            ],
            "cardinality": "1"
        },
        {
            "name": "master_namenode2",
            "configurations": [],
            "components": [
                {"name": "NAMENODE"},
                {"name": "ZKFC"},
                {"name": "RESOURCEMANAGER"},
                {"name": "METRICS_MONITOR"},
                {"name": "HISTORYSERVER"},
                {"name": "HIVE_METASTORE"},
                {"name": "HIVE_SERVER"},
                {"name": "JOURNALNODE"},
                {"name": "HIVE_CLIENT"},
                {"name": "HDFS_CLIENT"},
                {"name": "YARN_CLIENT"},
                {"name": "ZOOKEEPER_CLIENT"},
                {"name": "SPARK2_JOBHISTORYSERVER"},
                {"name": "SPARK2_CLIENT"},
                {"name": "MAPREDUCE2_CLIENT"},
                {"name": "TEZ_CLIENT"}
            ],
            "cardinality": "1"
        },
        {
            "name": "worker",
            "configurations": [],
            "components": [
                {"name": "HIVE_CLIENT"},
                {"name": "TEZ_CLIENT"},
                {"name": "SPARK2_CLIENT"},
                {"name": "YARN_CLIENT"},
                {"name": "DATANODE"},
                {"name": "METRICS_MONITOR"},
                {"name": "NODEMANAGER"}
            ],
            "cardinality": "1+"
        },
        {
            "name": "broker",
            "configurations": [],
            "components": [
                {"name": "ZOOKEEPER_SERVER"},
                {"name": "METRICS_MONITOR"},
                {"name": "ZOOKEEPER_CLIENT"}
            ],
            "cardinality": "3+"
        }
    ]
}