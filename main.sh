#install elk prerequisites
echo -e "\e[7minitial apt-get update\e[0m"
apt-get update
echo -e "\e[7minstall -y gnupg2\e[0m"
apt-get install -y gnupg2
echo -e "\e[7madd GPG key\e[0m"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
echo -e "\e[7mstart transport https install\e[0m"
apt-get install apt-transport-https
echo -e "\e[7madd package to source list\e[0m"
printf "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-7.x.list

#install elastic and kibana
echo -e "\e[7minstall elasticsearch\e[0m"
apt-get update && apt-get install elasticsearch=7.6.2

#GO TO ELASTICSEARCH.YML AND AFTER LINE 55 (network.host: 168.0...) AND INSTEAD WRITE network.host:localhost

echo -e "\e[7minstall kibana\e[0m"
apt-get update && apt-get install kibana=7.6.2

#install java
echo -e "\e[7minstall java\e[0m"
apt-get install -y software-properties-common
apt-get update
add-apt-repository -y ppa:linuxuprising/java
apt-get update
apt install -y openjdk-11-jre-headless

#install logstash and filebeat
echo -e "\e[7minstall logstash\e[0m"
apt-get update && apt-get install logstash=1:7.6.2-1
echo -e "\e[7minstall filebeat\e[0m"
apt-get update && apt-get install filebeat=7.6.2

#uncomment elasticsearch hosts line
echo -e "\e[7muncomment from kibana with sed\e[0m"
sed -i '/elasticsearch.hosts/s/^#//g' /etc/kibana/kibana.yml

#enabling filebeat
echo -e "\e[7menable service filebeat\e[0m"
systemctl enable filebeat

#starting elk
echo -e "\e[7menable service elastic\e[0m"
systemctl enable elasticsearch
echo -e "\e[7mstart service elastic\e[0m"
systemctl start elasticsearch

echo -e "\e[7menable service kibana\e[0m"
systemctl start kibana
echo -e "\e[7mstart service kibana\e[0m"
systemctl start kibana

echo -e "\e[7menable service logstash\e[0m"
systemctl enable logstash
echo -e "\e[7mstart service logstash\e[0m"
systemctl start logstash

#enable elasticsearch security
echo -e "\e[7menable elastic security\e[0m"
echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml

echo -e "\e[7mrestart service elastic\e[0m"
systemctl restart elasticsearch

#echo -e "\e[7minteractive password setup\e[0m"
#/usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive


echo -e "\e[7madd elastic bootstrap password\e[0m"
printf "#elastic2020PBL" | /usr/share/elasticsearch/bin/elasticsearch-keystore add "bootstrap.password"

echo -e "\e[7mpassword setup\e[0m"
curl -u elastic:#elastic2020PBL -XPOST "http://localhost:9200/_xpack/security/user/kibana/_password" -d'{"password":"#kibana2020PBL"}' -H "Content-Type: application/json"
curl -u elastic:#elastic2020PBL -XPOST "http://localhost:9200/_xpack/security/user/logstash_system/_password" -d'{"password":"#logstash2020PBL"}' -H "Content-Type: application/json"
curl -u elastic:#elastic2020PBL -XPOST "http://localhost:9200/_xpack/security/user/apm_system/_password" -d'{"password":"#apm-system2020PBL"}' -H "Content-Type: application/json"
curl -u elastic:#elastic2020PBL -XPOST "http://localhost:9200/_xpack/security/user/beats_system/_password" -d'{"password":"#beats2020PBL"}' -H "Content-Type: application/json"
curl -u elastic:#elastic2020PBL -XPOST "http://localhost:9200/_xpack/security/user/elastic/_password" -d'{"password":"#elastic2020PBL"}' -H "Content-Type: application/json"


echo -e "\e[7mcreating kibana keystore\e[0m"
/usr/share/kibana/bin/kibana-keystore create --allow-root

echo -e "\e[7madd kibana keystore user and pass\e[0m"
printf "kibana" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.username --allow-root
printf "#kibana2020PBL" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.password --allow-root

echo -e "\e[7mrestart kibana\e[0m"
systemctl restart kibana

#setting up credentials in kibana.yml
echo -e "\e[7msetting credentials in kibana.yml\e[0m"
sed -i '/^#elasticsearch.username.*/a elasticsearch.username: "kibana"' /etc/kibana/kibana.yml
sed -i '/^#elasticsearch.password.*/a elasticsearch.password: "#kibana2020PBL"' /etc/kibana/kibana.yml

echo -e "\e[7mrestart kibana\e[0m"
systemctl restart kibana


echo -e "\e[7mstop logstash\e[0m"
systemctl stop logstash

#here I should have uncommented xpack security from logstash.yml
#nano /etc/logstash/logstash.yml
# - uncomment the x-pack username and password
#username: logstash_system
#password: logstashsystem


echo -e "\e[7madd logstash keystore\e[0m"
printf "y" | /usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash/ create
echo -e "\e[7madd logstash keystore user and pass\e[0m"
printf "elastic" | /usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add ES_USER
printf "#elastic2020PBL" | /usr/share/logstash/bin/logstash-keystore --path.settings /etc/logstash add ES_PWD


echo -e "\e[7mmake new conf file in /etc/logstash/conf.d\e[0m"
cp ./zeek-logstash-pipeline.conf /etc/logstash/conf.d/


echo -e "\e[7mediting filebeat.yml\e[0m"
#delete the # from the line (the line that contains output.elasticsearch) if it's the first character
sed -i '/output.elasticsearch/s/^/#/' /etc/filebeat/filebeat.yml
#putting # at the beginning of line 150
sed -i '150 {s/^/#/}' /etc/filebeat/filebeat.yml
#delete the # from line 150 if it's the first character
sed -i '/output.logstash/s/^#//g' /etc/filebeat/filebeat.yml
#delete # from line 163 (did like so because there are two spaces in front)
sed -i '163 {s/#//}' /etc/filebeat/filebeat.yml

echo -e "\e[7menable zeek\e[0m"
filebeat modules enable zeek

echo -e "\e[7msetup zeek\e[0m"
filebeat setup -e

#backup for zeek.yml
echo -e "\e[7mbackup zeek.yml\e[0m"
cp /etc/filebeat/modules.d/zeek.yml /etc/filebeat/modules.d/zeek-threatnav-backup.yml.disabled
#new zeek.yml from our repo
echo -e "\e[7moverwrite original zeek.yml\e[0m"
cp ./zeek.yml /etc/filebeat/modules.d/zeek.yml

echo -e "\e[7mstart logstash\e[0m"
systemctl start logstash

echo -e "\e[7mbackup filebeat.yml\e[0m"
mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.backup

echo -e "\e[7mcopy yara edit over filebeat.yml\e[0m"
cp ./filebeat.yml /etc/filebeat/filebeat.yml

echo -e "\e[7mmake elasticsearch yara.results index mapping template\e[0m"
curl -X PUT -u elastic:#elastic2020PBL "localhost:9200/_template/template_1?pretty" -H 'Content-Type: application/json' -d'{"index_patterns":["yara_results"],"settings":{"number_of_shards":1},"mappings":{"properties":{"filename":{"type":"keyword"},"sent_over":{"type":"keyword"},"Yara_results":{"type":"nested","properties":{"rule":{"type":"keyword"},"namespace":{"type":"keyword"},"tags":{"type":"keyword"},"meta":{"type":"nested","properties":{"author":{"type":"keyword"},"original_author":{"type":"keyword"},"source":{"type":"keyword"}}}}}}}}'

echo -e "\e[7mcreate yara_results index\e[0m"
echo -e "\e[7myara_results will take the mapping from the above template\e[0m"
curl -X PUT -u elastic:#elastic2020PBL "localhost:9200/yara_results?pretty"

echo -e "\e[7mstart ingestion from filebeat\e[0m"
systemctl start filebeat

echo -e "\e[7munzip ngrok\e[0m"
unzip ngrok-stable-linux-amd64.zip

echo -e "\e[7minstall git\e[0m"
apt install git -y

echo -e "\e[7minstall nginx\e[0m"
apt-get install -y nginx apache2-utils

#creation of certs folders
mkdir -p /etc/pki/tls/certs
mkdir /etc/pki/tls/private

echo -e "\e[7mremove RANDFILE=... from /etc/ssl/openssl.cnf\e[0m"
sed -i '/RANDFILE/d' /etc/ssl/openssl.cnf

echo -e "\e[7mgetting IP of machine\e[0m"
IPv4=`dig +short myip.opendns.com @resolver1.opendns.com`
echo "$IPv4"

echo -e "\e[7madding IP to /etc/ssl/openssl.cnf\e[0m"
sed -i '227 a subjectAltName = IP: '"$IPv4" /etc/ssl/openssl.cnf

echo -e "\e[7mcreate new certificate for /etc/ssl/openssl.cnf\e[0m"
openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:4096 -keyout /etc/pki/tls/private/ELK-Stack.key -out /etc/pki/tls/certs/ELK-Stack.crt

echo -e "\e[7msetting up htpasswd credentials for yaraui login\e[0m"
htpasswd -b /etc/nginx/htpasswd.users elastic "#elastic2020PBL"
htpasswd -b /etc/nginx/htpasswd.users pblteacher QWERTY553

echo -e "\e[7mlinking htpasswd credentials to /etc/nginx/sites-available/yaraui\e[0m"
sed -i '/server_name/ a \ \ \ \ auth_basic_user_file /etc/nginx/htpasswd.users;' /etc/nginx/sites-available/yaraui
sed -i '/server_name/ a \ \ \ \ auth_basic "Restricted Access";' /etc/nginx/sites-available/yaraui

#https://discuss.elastic.co/t/how-to-create-build-in-user-without-interactive-mode-or-auto/183420/2

#https://discuss.elastic.co/t/how-to-set-passwords-for-built-in-users-in-batch-mode/119655/9
