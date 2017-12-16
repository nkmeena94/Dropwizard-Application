TEMP_SCHEMA=temp
DUMP_SQL=data_dump.list
merchants='120,402,416,506,421,422,423,424'
DBTODUMP=${MY_DB}

echo "creating schema dump"
mysqldump -u${MY_USER} -p${MY_PASS} -d ${DBTODUMP} -h ${MY_HOST}> dev_schema.sql
SQL="SET group_concat_max_len = 10240;"
SQL="${SQL} SELECT GROUP_CONCAT(table_name separator ' ')"
SQL="${SQL} FROM information_schema.tables WHERE table_schema='${DBTODUMP}'"
SQL="${SQL} AND table_name IN (
'auto_campaign_group',
'auto_campaign_template',
'campaign_types',
'channel',
'channellabel',
'config',
'cta_template',
'custom_report',
'email_core',
'loyalty',
'msm',
'notification_types',
'offer_template',
'push_notification_core',
'recommendations',
'sms_core',
'sms_template',
'sms_templates',
'special_event',
'subscription_plans',
'user_merchant_map'
)"

TBLIST=`$MYSQL_CON -AN -e"${SQL}"`
echo "creating seed dump for tables $TBLIST"
mysqldump -u${MY_USER} -p${MY_PASS} ${DBTODUMP} ${TBLIST} -h ${MY_HOST}> dev_dump.sql

echo "creating data dump using merhcant $merchants"
echo "drop database $TEMP_SCHEMA ; " > $DUMP_SQL
#echo "drop database $TEMP_SCHEMA" | $MYSQL_CON
echo "create database $TEMP_SCHEMA ; " >> $DUMP_SQL
#echo "create database $TEMP_SCHEMA" | $MYSQL_CON

for line in `cat data_tables`
do
    table=`echo $line | cut -f1 -d':'`
    col=`echo $line | cut -f2 -d':'`
	filter=`echo $line |  cut -f3 -d':'`
	[ -z "$filter" ] && filter="1"
    echo "create table ${TEMP_SCHEMA}.$table as select * from ${table} where ${col} in (${merchants}) and ${filter} ;" >> $DUMP_SQL
done

echo "create table ${TEMP_SCHEMA}.customers as select * from customers where id in (select customer_id from customers_merchant_map where merchant_id in (${merchants})) ;" >> $DUMP_SQL
echo "create table ${TEMP_SCHEMA}.users as select * from users where id in (select user_id from user_merchant_map where map_id in (${merchants})) ;" >> $DUMP_SQL
cat $DUMP_SQL | $MYSQL_CON -D $MY_DB

mysqldump -u${MY_USER} -p${MY_PASS} ${TEMP_SCHEMA} -h ${MY_HOST} --no-create-info > data_dump.sql
