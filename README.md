# docker-couchdb

This docker is for development purposes only.

A docker container for running [CouchDB](https://couchdb.apache.org/) server
 which extends [docker-library/couchdb](https://github.com/klaemo/docker-couchdb) as base.

## How to run

The container can be run as a CouchDB server:
```
docker run -d --name couchdb -p 5984:5984 \
           -e COUCHDB_USER=admin -e COUCHDB_PASSWORD=password \
           -v $HOME/data-couchdb:/usr/local/var/lib/couchdb \
           mcreations/couchdb 
```

For testing the server use:
```
curl http://127.0.0.1:5984/
```

You should see the following response:
```
{"couchdb":"Welcome","uuid":"fedf61e4b737d055c1856a2f41ce6563","version":"1.6.1","vendor":{"version":"1.6.1","name":"The Apache Software Foundation"}}
```

#For more informaion 

https://github.com/docker-library/docs/tree/master/couchdb

https://github.com/klaemo/docker-couchdb

# Github Repo

https://github.com/m-creations/docker-couchdb
