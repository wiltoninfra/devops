    1  vim /etc/ssh/sshd_config 
    2  systemctl restart sshd
    3  hostnamectl set-hostname docker
    4  bash
    5  vim /etc/network/interfaces
    6  ip a
    7  systemctl restart networking.service 
    8  reboot
    9  ip a
   10  cat /etc/network/interfaces
   11  reboot
   12  ip a
   13  vim /etc/network/interfaces
   14  reboot
   15  ip a
   16  ping 8.8.8.8
   17  ping google.com.br
   18  cat /etc/resolv.conf 
   19  vim /etc/resolvconf/resolv.conf.d/base 
   20  reboot
   21  cat /etc/hosts
   22  apt-get install apt-transport-https ca-certificates curl software-properties-common -y
   23  iptable -l
   24  iptables -l
   25  iptables -L
   26  iptables -F
   27  iptables -F -NAT -N
   28  iptables -F -NAT
   29  iptables -t nat -F
   30  iptables -F
   31  service httpd start
   32  iptables -F
   33  halt
   34  ls
   35  docker ps
   36  docker run --name primeiro debian /bin/ls /etc
   37  docker ps -a
   38  docker start primeiro
   39  docker attach primeiro
   40  docker stop primeiro
   41  docker attach primeiro
   42  docker start
   43  docker start primeiro
   44  docker attach primeiro
   45  docker stop
   46  docker stop primeiro
   47  docker rm primeiro
   48  docker run -it --name primeiro debian /bin/bash
   49  docker pull centos
   50  ks
   51  ls
   52  docker colume create --name data
   53* docker volume create --name data
   54  docker volume -ls
   55  docker volume ls
   56  docker volume
   57  docker volume inspect
   58  docker volume inspect data
   59* docker run -it --name volume-teste -v data:/data debian /bin/bash 
   60  system ctl apache2
   61  systemctl stop apache2
   62  docker run -it -p 80:80 --name webs nginx /bin/bash
   63  docker ps -a
   64  docker images
   65  docker network ls
   66  docker network create --subnet 10.0.0.0/16
   67  docker network create --subnet 10.0.0.0/16 dexterlam
   68  docker network create --subnet 10.0.0.0/16 dexterlan
   69  docker network ls
   70  docker run -it --name node01 --hostname node01 --net dexterlan debian /bin/bash
   71  docker run -it --name node01 --hostname node01 --net dexterlam debian /bin/bash
   72  docker run -it -p 80:80 --name webs nginx /bin/bash
   73  docker ps -a
   74  docker run -it --name node01 --hostname node01 --net dexterlam debian /bin/bash
   75  docker rm node01
   76  docker run -it --name node01 --hostname node01 --net dexterlam debian /bin/bash
   77  docker network connect dexterlan webs
   78  docker network connect dexterlam webs
   79  docker run -dit --name webnode --hostname webnode --ip 10.10.0.10 --net dexterlam debian /bin/bash
   80  docker run -dit --name webnode --hostname webnode --ip 10.0.0.10 --net dexterlam debian /bin/bash
   81  docker run -dit --name webnode --hostname webnode1 --ip 10.0.0.10 --net dexterlam debian /bin/bash
   82  docker run -dit --name webnode1 --hostname webnode1 --ip 10.0.0.10 --net dexterlam debian /bin/bash
   83  docker ps -a
   84  docker exec webnode1 ip a
   85  curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-Linux-x86_64 > /usr/bin/docker-compose
   86  docker-compose up
   87  mv /usr/bin/docker-compose /usr/local/bin/
   88  docker-compose --version
   89  mv /usr/local/bin/docker-compose /usr/bin/
   90  docker-compose --version
   91  chmod +x /usr/bin/docker-compose 
   92  docker-compose --version
   93  vim docker-compose.yml
   94  docker-compose . build
   95  docker-compose . --build
   96  docker-compose --build
   97  docker-compose build .
   98  docker-compose build
   99  docker ps
  100  docker-compose up -d
  101  docker ps -a
  102  history > docker-commands.md
