for /f %%i in ('mkcert -CAROOT') do set MKCERT=%%i
multipass transfer "%MKCERT%\rootCA.pem" dev:/home/ubuntu/rootCA.pem
multipass transfer "%MKCERT%\rootCA-key.pem" dev:/home/ubuntu/rootCA-key.pem

multipass transfer "%~dp010-https-http2.sh" dev:/tmp/x.sh
multipass exec dev sudo chmod 777 /tmp/x.sh
multipass exec dev sudo /tmp/x.sh
multipass exec dev sudo rm /tmp/x.sh