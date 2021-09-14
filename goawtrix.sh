#!/bin/bash
echo -e "\033[36mAwtrix2 Docker Container Maker\033[0m"
echo "by AkagiYui"

port_web=$1
port_esp=$2
container_name=$3

if [ -z "$port_web" ]
then
	echo "Set default web port: 7000"
	port_web=7000
else
	echo "Set web port: $port_web"
fi

if [ -z "$port_esp" ]
then
        echo "Set default esp8266 port: 7001"
	port_esp=7001
else
        echo "Set web port: $port_esp"
fi

if [ -z "$container_name" ]
then
        echo "Use random container name."
else
        echo "Set container name: $container_name"
	container_name="--name "$container_name
fi

if command -v wget > /dev/null
then
	echo 1 > /dev/null
else
	echo -e "\033[31mPlease install wget manually.\033[0m"
	exit 1
fi

if docker version | grep "Server: Docker" > /dev/null 2>&1
then
	echo 1 > /dev/null 
else
	echo -e "\033[31mMake sure your Docker Engine is running!\033[0m"
	exit 2
fi

path=$(pwd)
echo "Start download awtrix server jar package..."

wget -O $path/awtrix.jar https://blueforcer.de/awtrix/stable/awtrix.jar
echo ""

echo "Building Container..."

rm -f Dockerfile
cat > Dockerfile <<EOF
FROM alpine:3
RUN mkdir /awtrix \\
    && apk add openjdk8-jre --no-cache\\
    && apk add tzdata --no-cache \\
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \\
    && echo "Asia/Shanghai" > /etc/timezone
WORKDIR /awtrix
EXPOSE 7000 7001
CMD ["java","-jar","/awtrix/awtrix.jar"]
EOF

docker build -t awtrix-server:2021.9.10 . > /dev/null

runCommand="docker run "
runCommand=$runCommand$container_name
runCommand=$runCommand" -p $port_web:7000 -p $port_esp:7001 -v $path:/awtrix --restart always -d awtrix-server:2021.9.10"
container_id=$($runCommand)

result=$(docker container ls -a -f id=$container_id)
container_name=$(echo $result | sed -n '$p' | sed 's/^.* //g')

echo -e "Container name: \033[36m$container_name\033[0m"

if echo $result | grep "Up" > /dev/null
then
	echo 1 > /dev/null
else
	echo -e "Building container \033[31mfailed\033[0m, please check!"
	exit 1
fi

sleep 2
logs=$(docker container logs $container_id)
echo $logs

echo -e "Awtrix Server is \033[36mrunning\033[0m now."
ip=$(ip addr | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}' | sed -n "1p")
echo -e "Browse \033[36mhttp://$ip:$port_web\033[0m"
