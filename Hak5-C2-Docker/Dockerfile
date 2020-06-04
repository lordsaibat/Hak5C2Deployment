ARG hostname
ARG listenport
FROM kalilinux/kali-rolling:latest
RUN apt-get update && apt install unzip wget -y

RUN mkdir hak5
WORKDIR hak5
RUN wget https://c2.hak5.org/download/community
RUN unzip community
RUN chmod +x c2_community-linux-64

# Persistent db
# RUN mkdir db
# CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} -db ./db/c2.db #http version
# CMD ./c2_community-linux-64 -hostname ${hostname} -listenport {listenport} -https -db ./db/c2.db #https version (needs hostname)
# end Persistent db

CMD ./c2_community-linux-64 -hostname ${hostname} -listenport ${listenport} #http version
# CMD ./c2_community-linux-64 -hostname ${hostname} -listenport {listenport}  -https #https version (needs hostname)