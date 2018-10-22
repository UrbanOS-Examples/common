export UAA_DEFAULT_SECRET=${UAA_DEFAULT_SECRET}
export UAA_DEFAULT_USER_PW=${UAA_DEFAULT_USER_PW}
export UAA_DEFAULT_USER_EMAIL=${UAA_DEFAULT_USER_EMAIL}
export PUBLIC_IP=${PUBLIC_IP}
export CB_HOST_ADDRESS=$(hostname -i)

export DATABASE_HOST=${DATABASE_HOST}
export DATABASE_PORT=${DATABASE_PORT}
export DATABASE_USERNAME=${DATABASE_USERNAME}
export DATABASE_PASSWORD=${DATABASE_PASSWORD}

export CB_DB_PORT_5432_TCP_ADDR=$DATABASE_HOST
export CB_DB_PORT_5432_TCP_PORT=$DATABASE_PORT
export CB_DB_ENV_USER=$DATABASE_USERNAME
export CB_DB_ENV_PASS=$DATABASE_PASSWORD
export CB_DB_ENV_DB=cbdb

export PERISCOPE_DB_PORT_5432_TCP_ADDR=$DATABASE_HOST
export PERISCOPE_DB_PORT_5432_TCP_PORT=$DATABASE_PORT
export PERISCOPE_DB_ENV_USER=$DATABASE_USERNAME
export PERISCOPE_DB_ENV_PASS=$DATABASE_PASSWORD
export PERISCOPE_DB_ENV_DB=periscopedb
export PERISCOPE_DB_ENV_SCHEMA=public

export IDENTITY_DB_URL=$DATABASE_HOST:$DATABASE_PORT
export IDENTITY_DB_USER=$DATABASE_USERNAME
export IDENTITY_DB_PASS=$DATABASE_PASSWORD
export IDENTITY_DB_NAME=uaadb