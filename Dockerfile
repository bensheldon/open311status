FROM ubuntu:16.04

ENV HOME /home
RUN mkdir -p $HOME

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  libexpat1-dev \
  g++ \
  gcc \
  git \
  libxml2-dev \
  nodejs \
  npm \
  sudo

RUN addgroup --gid=1000 myuser && \
    adduser --system --uid=1000 --home /home --shell /bin/bash myuser && \
    echo "myuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown -hR myuser:myuser /home && \
    chown -hR myuser:myuser /usr/local
USER myuser

RUN mkdir /usr/local/app
WORKDIR /usr/local/app

RUN npm config set strict-ssl false && \
  npm install -g n && \
  n 7.3

ENV NODE_PATH /usr/local/bin/node

COPY --chown=myuser:myuser package*.json ./
RUN npm install --unsafe-perm || npm install --unsafe-perm

COPY --chown=myuser:myuser . .

ENV PORT 3000
EXPOSE 3000
CMD [ "npm", "start" ]
