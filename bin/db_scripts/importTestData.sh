USER=$1
PASS=$2
HOST=$3
DB=$4

echo "drop database ${DB}" | mysql -u${USER} -p${PASS} -h${HOST}
echo "create database ${DB}" | mysql -u${USER} -p${PASS} -h${HOST}

mysql -u${USER} -p${PASS} -h${HOST} -D ${DB} < dev_schema.sql
mysql -u${USER} -p${PASS} -h${HOST} -D ${DB} < dev_dump.sql
mysql -u${USER} -p${PASS} -h${HOST} -D ${DB} < data_dump.sql
