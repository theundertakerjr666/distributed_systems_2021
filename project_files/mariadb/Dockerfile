FROM mariadb:10.5.6

RUN apt-get update
RUN apt-get install -y tzdata

COPY first-run.sh /first-run.sh
COPY entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
