FROM ubuntu:12.10
RUN apt-get update
RUN apt-get install -y nodejs npm wget git s3cmd python-magic
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g hem@0.1.9
ADD build.sh /build/build.sh
ADD s3cfg /build/s3cfg
