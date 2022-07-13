#! /bin/bash
# Doc https://github.com/FiloSottile/mkcert
sudo apt install libnss3-tools
wget -O mkcert https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64
sudo chmod +x ./mkcert
./mkcert -install
./mkcert -cert-file ./../config/ssl/server.cert -key-file ./../config/ssl/server.key sefu.test "*.sefu.test"