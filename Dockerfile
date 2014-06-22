FROM debian:7.4
RUN echo "deb http://http.debian.net/debian/ wheezy-backports main" >> /etc/apt/sources.list
RUN apt-get update

# Install node and NPM
RUN apt-get install -y nodejs nodejs-legacy
RUN apt-get install -y curl moreutils
RUN curl https://www.npmjs.org/install.sh | sponge | clean=no sh

# Basics for building and testing
RUN npm install coffee-script@1.7.1
RUN npm install uglify-js@2.4.13
RUN npm install stylus@0.43.0

ENV PATH $PATH:/node_modules/.bin

# Install jekyll + pygments for building docs
RUN apt-get install -y jekyll
RUN apt-get install -y python-pygments

WORKDIR /colorspaces
