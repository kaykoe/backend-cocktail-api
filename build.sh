#!/bin/bash
cp ./.env.example ./.env
echo "TZ=UTC" > ./.env
echo "HOST=0.0.0.0" >> ./.env
echo "LOG_LEVEL=info" >> ./.env
echo "NODE_ENV=production" >> ./.env
echo "DRIVE_DISK=fs" >> ./.env
echo "APP_DOMAIN=0.0.0.0:$PORT" >> ./.env
echo $DATABASE_URL | awk -F'[/:@]' '
/postgres:\/\// {
    split($8, a, "?")
    print "DB_USER=" $4 >> ".env"
    print "DB_PASSWORD=" $5 >> ".env"
    print "DB_HOST=" $6 >> ".env"
    print "DB_PORT=" $7 >> ".env"
    print "DB_DATABASE=" a[1] >> ".env"
}
' 2>/dev/null
node ace build
cp ./.env ./build/.env

