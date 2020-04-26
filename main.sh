#install elk prerequisites
apt-get install -y gnupg2
sleep 10s
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get install apt-transport-https
sleep 5s
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sleep 10s

#install elastic and kibana
sudo apt-get update && sudo apt-get install elasticsearch=7.6.2
sleep 60s
apt-get update && sudo apt-get install kibana=7.6.2
sleep 60s

#install java
sudo apt-get install -y software-properties-common
sleep 10s
apt-get update
sleep 10s
add-apt-repository -y ppa:linuxuprising/java
sleep 10s
sudo apt-get update
sleep 20s
apt install -y openjdk-11-jre-headless
sleep 20s

#install logstash and filebeat
apt-get update && sudo apt-get install logstash=1:7.6.2-1
sleep 60s
apt-get update && sudo apt-get install filebeat=7.6.2
sleep 30s

#uncomment elasticsearch hosts line
sed -i '/elasticsearch.hosts/s/^#//g' /etc/kibana/kibana.yml
sleep 2s

#starting elk
systemctl start elasticsearch
sleep 30s
systemctl start kibana
sleep 30s
systemctl start logstash
sleep 30s

#enable elasticsearch security
echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
sleep 2s
echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml
sleep 2s

systemctl restart elasticsearch
sleep 30s
systemctl stop elasticsearch
sleep 10s

printf "#elastic2020PBL" | /usr/share/elasticsearch/bin/elasticsearch-keystore add "bootstrap.password"
sleep 10s

curl -u elastic:"#elastic2020PBL" -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password 61' -d '{ "password”:#kibana2020PBL }'
sleep 10s

curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password' -d '{ "password":"#kibana2020PBL" }'
sleep 10s
