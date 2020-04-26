#install elk prerequisites
apt-get install -y gnupg2
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get install apt-transport-https
apt-get update
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

#install elastic and kibana
apt-get update && apt-get install elasticsearch=7.6.2
apt-get update && apt-get install kibana=7.6.2

#install java
apt-get install -y software-properties-common
apt-get update
add-apt-repository -y ppa:linuxuprising/java
apt-get update
apt install -y openjdk-11-jre-headless

#install logstash and filebeat
apt-get update && apt-get install logstash=1:7.6.2-1
apt-get update && apt-get install filebeat=7.6.2

#uncomment elasticsearch hosts line
sed -i '/elasticsearch.hosts/s/^#//g' /etc/kibana/kibana.yml

#starting elk
systemctl start elasticsearch
systemctl start kibana
systemctl start logstash

#enable elasticsearch security
echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml

systemctl restart elasticsearch

#https://discuss.elastic.co/t/how-to-create-build-in-user-without-interactive-mode-or-auto/183420/2

#https://discuss.elastic.co/t/how-to-set-passwords-for-built-in-users-in-batch-mode/119655/9

printf "#elastic2020PBL" | /usr/share/elasticsearch/bin/elasticsearch-keystore add "bootstrap.password"

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password' -d '{ "password":"#kibana2020PBL" }'

/usr/share/kibana/bin/kibana-keystore create --allow-root

printf "kibana" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.username --allow-root

printf "#kibana2020PBL" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.password --allow-root

systemctl restart kibana

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password' -d '{ "password":"#kibana2020PBL" }'

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/logstash_system/_password' -d '{ "password":"#logstash2020PBL" }'

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/apm_system/_password' -d '{ "password":"#apmsystem2020PBL" }'

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/beats_system/_password' -d '{ "password":"#beats2020PBL" }'

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/elastic/_password' -d '{ "password":"#elastic2020PBL" }'





#/usr/share/kibana/bin/kibana-keystore create --allow-root
#sleep 3s

#printf "kibana" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.username --allow-root
#sleep 3s

#printf "#kibana2020PBL" | /usr/share/kibana/bin/kibana-keystore add elasticsearch.password --allow-root
#sleep 3s

#systemctl restart kibana
#sleep 30s

