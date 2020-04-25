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