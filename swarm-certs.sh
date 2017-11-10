#!/bin/bash

HOSTNAME="$(hostname)"

export ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4/)

openssl genrsa -out ca-key.pem 4096

openssl req -new -x509 -nodes -days 365 -subj "/CN=${HOSTNAME}" -key ca-key.pem -sha256 -out ca.pem

openssl genrsa -out server-key.pem 4096

openssl req -subj "/CN=${ip}" -sha256 -new -key server-key.pem -out server.csr

echo subjectAltName = DNS:${ip},IP:${ip} >> extfile.cnf

echo extendedKeyUsage = serverAuth >> extfile.cnf

openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -extfile extfile.cnf

openssl genrsa -out key.pem 4096

openssl req -subj '/CN=client' -new -key key.pem -out client.csr

echo extendedKeyUsage = clientAuth >> extfile.cnf

openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -extfile extfile.cnf

sudo rm -v client.csr server.csr

chmod -v 0400 ca-key.pem key.pem server-key.pem
#chmod -v 0444 key.pem
chmod -v 0444 ca.pem server-cert.pem cert.pem

