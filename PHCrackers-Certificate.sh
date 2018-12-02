#!/bin/sh
PUBLIC_IP=`curl -s http://ifconfig.me/ip`

echo "Server Public IP ${PUBLIC_IP}"

# Download Master Certificate and extract to /etc/openvpn
cd /etc/openvpn
rm -Rf easy-rsa

wget -q https://github.com/piolomartin/PHCrackers-Certificate/raw/master/easy-rsa.zip -O easy-rsa.zip
unzip easy-rsa.zip

cp easy-rsa/keys/server.crt .
cp easy-rsa/keys/server.key .

cp easy-rsa/keys/ca.crt .
cp easy-rsa/keys/ca.key .


if [ -f /home/vps/public_html/client.ovpn ]; then
    rm -f /home/vps/public_html/client.ovpn
fi
if [ -f /home/vps/public_html/openvpn.tar.gz ]; then
    rm -f /home/vps/public_html/openvpn.tar.gz
fi

#Create New Client Config
cat > /home/vps/public_html/client.ovpn <<-END
# Created by PHCrackersAdmin

client
dev tun
proto tcp
remote ${PUBLIC_IP} 1194
persist-key
persist-tun
dev tun
pull
resolv-retry infinite
nobind
user nobody
group nogroup
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
script-security 2
route 0.0.0.0 0.0.0.0
route-method exe
route-delay 2
cipher AES-128-CBC
http-proxy ${PUBLIC_IP} 8080
http-proxy-retry

END

echo '<ca>' >> /home/vps/public_html/client.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/client.ovpn
echo '</ca>' >> /home/vps/public_html/client.ovpn
cd /home/vps/public_html/
tar -czf /home/vps/public_html/openvpn.tar.gz client.ovpn
tar -czf /home/vps/public_html/client.tar.gz client.ovpn

echo "Done, please reboot/restart your server."
