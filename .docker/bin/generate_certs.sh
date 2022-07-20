#! /bin/bash
# Doc https://github.com/FiloSottile/mkcert

FILE=./mkcert
if [ ! -f "$FILE" ]; then
    sudo apt install libnss3-tools
    wget -O mkcert "https://github.com/FiloSottile/mkcert/releases/download/v$2/mkcert-v$2-linux-amd64"
    sudo chmod +x ${FILE}
    sudo chown -R $USER:$USER ${FILE}
else
    ./mkcert -uninstall
fi

./mkcert -install
./mkcert -cert-file ./../config/ssl/server.cert -key-file ./../config/ssl/server.key $1 "*.$1"