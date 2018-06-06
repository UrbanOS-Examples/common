[
  {
    "name": "${name}",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memoryReservation},
    "essential": true,
    "portMappings": [
        {
            "containerPort": ${port},
            "hostPort": ${port}
        },
        {
            "containerPort": 8082,
            "hostPort": 8082
        },
        {
            "containerPort": 8083,
            "hostPort": 8083
        }
    ],
    "mountPoints": [
          {
            "sourceVolume": "${directory_name}",
            "containerPath": "/${directory_name}"
          }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${region}"
      }
    }
  }
]
