### This might or might not be required. I forgot
```bash
apt-get install iptables-persistent
```

### Open port 80
```bash
sudo iptables -I INPUT -i eth0 -p tcp --dport 80 -m comment --comment "# http  #" -j ACCEPT
```

### Open port 443
```bash
sudo iptables -I INPUT -i eth0 -p tcp --dport 443 -m comment --comment "# https  #" -j ACCEPT
```
