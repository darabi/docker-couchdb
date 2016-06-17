#!/bin/bash

############################################
# Base Functions' Declaration
###########################################
function wait_until_service_comes_up() {
  local couchdb_url=$1
  echo "... wait until $couchdb_url comming up to create databases ..."
  while true; do
    HTTP_CODE=$(curl -sL -w "%{http_code}\\n"  --connect-timeout 1 -o /dev/null -XGET "$couchdb_url")
    if [ 200 -eq $HTTP_CODE ]; then
      echo "CouchDB service on $couchdb_url is up ..."
      break
    elif [ 000 -eq $HTTP_CODE ]; then
      sleep 1
      echo "... wait until $couchdb_url comming up to create databases ..."
    else
      sleep 1
      echo "... wait until $couchdb_url comming up to create databases (HttpCode is ${HTTP_CODE}) ..."      
    fi
  done
}


############################################
function check_database_exits(){
  local couchdb_url=$1 database_name=$2
  HTTP_CODE=$(curl -sL -w "%{http_code}\\n"  --connect-timeout 10 -o /dev/null -XGET "${couchdb_url}/${database_name}")
  if [ 200 -eq $HTTP_CODE ]; then 
    #0=true
    return 0
  else
    echo "$database_name database does not exist on CouchDB."
    #1=false
    return 1
  fi
}

############################################
function creare_database(){
  local couchdb_url=$1 database_name=$2
  HTTP_CODE=$(curl -sL -w "%{http_code}\\n" --connect-timeout 30 -XPUT "${couchdb_url}/${database_name}"  -o /dev/null)
  if [[ ( 200 -eq $HTTP_CODE ) || ( 201 -eq $HTTP_CODE ) ]]; then
    echo "database $database_name created successfully on CouchDB."    
    #0=true
    return 0
  else
    echo "Create database $database_name failed with HTTP code: $HTTP_CODE"
    #1=false
    return 1
  fi  
}

############################################
# Main Secion of Script
###########################################
exec tini -s -- /docker-entrypoint.sh couchdb &

pid=$!

echo "Process ID of CouchDB : $pid"


wait_until_service_comes_up "http://localhost:5984"


if [ ! -z ""$DATABASES_NAME"" ]; then
IFS=',' read -a db_array <<< "$DATABASES_NAME"
echo "#--------------------------------------------"
echo "Creating databases ..."
echo "---------------------------------------------"
for i in "${db_array[@]}"
do
   echo "Creating database $i ... "
   creare_database "http://${COUCHDB_USER}:${COUCHDB_PASSWORD}@localhost:5984" "$i"
   echo "---------------------------------------------"
done
echo "Creating databases done."
echo "--------------------------------------------#"
fi 

################ Check if any internal databases exists #############################
#ls -1 ${INTERNAL_TEMPLATCouchDB_DIR}/*.json > /dev/null 2>&1
#if [ "$?" = "0" ]; then
#  echo "#--------------------------------------------"  
#  echo "Checking internal databases to import ..."  
#  create_databases "http://localhost:9200" ${INTERNAL_TEMPLATCouchDB_DIR}
#  echo "Creating internal databases on CouchDB Done."
#  echo "---------------------------------------------#"
#fi
#
################ Check if any external databases exists #############################
#ls -1 ${EXTERNAL_TEMPLATCouchDB_DIR}/*.json > /dev/null 2>&1
#if [ "$?" = "0" ]; then
#  echo "#--------------------------------------------"  
#  echo "Checking external databases to import ..."  
#  create_databases "http://localhost:9200" ${EXTERNAL_TEMPLATCouchDB_DIR}
#  echo "Creating external databases on CouchDB Done."
#  echo "---------------------------------------------#"
#fi
wait
