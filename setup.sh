#!/bin/bash
head -n -6 ./.env > tempfile && mv tempfile ./.env
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
cp ./.env ./build/.env

