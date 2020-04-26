#install elk prerequisites
apt-get install -y gnupg2
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

#install elastic and kibana
sudo apt-get update && sudo apt-get install elasticsearch=7.6.2
apt-get update && sudo apt-get install kibana=7.6.2

#install java
sudo apt-get install -y software-properties-common
apt-get update
add-apt-repository -y ppa:linuxuprising/java
sudo apt-get update
apt install -y openjdk-11-jre-headless

#install logstash and filebeat
apt-get update && sudo apt-get install logstash=1:7.6.2-1
apt-get update && sudo apt-get install filebeat=7.6.2

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
systemctl stop elasticsearch

printf "#elastic2020PBL" | /usr/share/elasticsearch/bin/elasticsearch-keystore add "bootstrap.password"

curl -u elastic:"#elastic2020PBL" -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password 61' -d '{ "password”:#kibana2020PBL }'


curl -u elastic:#elastic2020PBL -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password' -d '{ "password”:#kibana2020PBL }'


root@ubuntu:/home/tepa7019# curl -u elastic:"#elastic2020PBL" -XPUT -H 'Content-Type: application/json' 'http://localhost:9200/_xpack/security/user/kibana/_password' -d '{ "password”:"#kibana2020PBL" }'
{"error":{"root_cause":[{"type":"json_parse_exception","reason":"Unexpected character ('#' (code 35)): was expecting a colon to separate field name and value\n at [Source: org.elasticsearch.transport.netty4.ByteBufStreamInput@10613a2b; line: 1, column: 18]"}],"type":"json_parse_exception","reason":"Unexpected character ('#' (code 35)): was expecting a colon to separate field name and value\n at [Source: org.elasticsearch.transport.netty4.ByteBufStreamInput@10613a2b; line: 1, column: 18]"},"status":400}root@ubuntu:/home/tepa7019# 
