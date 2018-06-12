[
 {
   "name" : "joomla",
   "image": "joomla:3.8.7-php5.6",
   "essential": true,
   "environment" : [{ "name" : "JOOMLA_DB_HOST", "value" : "${db_host}"},
   { "name" : "JOOMLA_DB_USER", "value" : "${db_user}"},
   { "name" : "JOOMLA_DB_PASSWORD", "value" : "${db_password}"},
   { "name" : "JOOMLA_DB_NAME", "value" : "${db_name}"}],
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }],
      "memory": ${memory}
 }
]
