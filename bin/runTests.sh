#!/bin/bash
ENV_ID=$1
API_KEY=$2
EXT_URL=$3
export BASE_URL="localhost:${APP_PORT}"
curl https://api.getpostman.com/environments/${ENV_ID}?apikey=${API_KEY} > env.json
#echo '{"globals":{"name":"GlobalsHack","values":[{"enabled":true,"type":"text","key":"baseUrl","value":"'${BASE_URL}'"}]}}' > globals.json
sed -i "s/environment/globals/g" env.json
sed -i "s/${EXT_URL}/${BASE_URL}/g" env.json

for entry in `cat ./bin/collections.list | grep -v "\-\-"`
do
	collection=`echo $entry | cut -f2 -d'='`
	name=`echo $entry | cut -f1 -d'='`
	echo "Running collection : $name $collection"  
	newman run https://www.getpostman.com/collections/${collection}?apikey=${API_KEY} --globals env.json
	[ ! $? == 0 ] && exit 1
done
exit 0

