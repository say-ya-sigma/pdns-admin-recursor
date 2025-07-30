FROM alpine:latest

RUN apk add --no-cache pdns-recursor

RUN mkdir -p /var/run/pdns-recursor

COPY recursor.conf /etc/pdns/recursor.conf

CMD [ "/usr/sbin/pdns_recursor" ]
