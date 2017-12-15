FROM ubuntu
RUN apt-get update
RUN apt-get install wget -y
RUN wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
RUN dpkg -i puppetlabs-release-pc1-xenial.deb
RUN apt-get update && apt-get install puppet-agent git vim -y
RUN apt-get install apache2 -y
RUN mkdir -p /root/.ssh/
COPY id_rsa /root/.ssh/
COPY config /root/.ssh/
COPY puppet.conf /etc/puppetlabs/puppet/puppet.conf

