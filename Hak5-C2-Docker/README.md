# Environment Setup Instructions

## Tools needed
- docker
- docker-compose

### Installation instructions
- Docker [https://docs.docker.com/get-docker/]
- Docker-compose [https://docs.docker.com/compose/install/]

# Todo before you try to deploy
## HTTPS Version
You will need a dns entry that will point to this system.

If you want to use https version comment the thrid CMD line in the Dockerfile.

`# CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} #http version `

and uncomment the fourth line.

`CMD ./c2_community-linux-64 -hostname ${hostname} -listenport {listenport}  -https #https version (needs hostname)`

# Deployment instructions
All the follwing commands need to be ran in the directory where the Dockerfile or docker-compose.yml is at.
## Docker Deployment
Build the docker file and tag it.
`sudo docker build . -t hak5c2`

This will be a fresh C2 everytime this is ran.
Run the new containter built
`sudo docker run --network=host -e 'hostname=192.168.2.192' -e 'listenport=80' hak5c2`

## Docker-Compose Deployment
Build the docker-compose file and tag it.
`sudo docker-compose build`

Run the docker-compose
`sudo docker-compose run --service-ports -e 'hostname=192.168.2.192' -e 'listenport=80' hak5-c2`

# Limitations
Docker containers are naturally ephimeral (they are gone after they are closed)

This container uses the default port for the ssh port needed for Cloud C2 (2022)

## Add persistent storage
## Docker 
Edit the Dockerfile and remove the comment for making the db directory, the http/https version of C2, and comment the other CMD.

### Example 
For Http

```
# Persistent db
RUN mkdir db
CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} -db ./db/c2.db #http version
# CMD ./c2_community-linux-64 -hostname ${hostname} -listenport {listenport} -https -db ./db/c2.db #https version (needs hostname)
# end Persistent db

#CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} #http version
```

or for https

```
# Persistent db
RUN mkdir db
# CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} -db ./db/c2.db #http version
CMD ./c2_community-linux-64 -hostname ${hostname} -listenport {listenport} -https -db ./db/c2.db #https version (needs hostname)
# end Persistent db

#CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} #http version
```

### Run the container
`sudo docker run --network=host -e 'hostname=192.168.2.192' -e 'listenport=80' -v $(pwd):/hak5/db/ hak5c2`

## Docker-Compose 
Follow the above instructions for Docker.

### Run the container
`sudo docker-compose run --service-ports -e 'hostname=192.168.2.192' -e 'listenport=80' -v $(pwd):/hak5/db/ hak5-c2`

### Changing ports 
- Edit the docker-compose.yml
  - update the ports to match the ones you would like.