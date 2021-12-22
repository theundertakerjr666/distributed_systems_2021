FROM nginx:1.19.5-perl

MAINTAINER Justin_Helsinki <justin_anthony@helsinki.fi>
USER root

RUN apt -y update && apt install -y python3 python3-pip wget certbot mosquitto mosquitto-clients openssl
RUN pip3 install paho-mqtt
RUN apt -y upgrade
RUN apt install -y net-tools rsyslog rsyslog-doc telnet
#COPY letsencrypt /etc/letsencrypt
RUN mkdir -p /etc/ssl/private
RUN chmod 700 /etc/ssl/private
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt  -subj "/C=FI/ST=Helsinki/L=Helsinki/O=Helsinki/OU=IT Department/CN=distribution.local"

RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
EXPOSE 443
#CMD ["/usr/sbin/init"]
#CMD ["/bin/bash"]

#EXPOSE 443 
#CMD service nginx start
CMD ["/usr/sbin/nginx"]
