FROM alpine:latest as main

RUN set -eux; \
    apk --update add bash openssh-client ruby git ruby-json python3 py3-pip openssl ca-certificates; \
    apk --update add --virtual \
      build-dependencies \
      build-base \
      python3-dev \
      libffi-dev \
      openssl-dev; \
    pip3 install --upgrade pip cffi; \
    pip3 install ansible boto pywinrm; \
    apk del build-dependencies; \
    rm -rf /var/cache/apk/*; \
    mkdir -p /etc/ansible; \
    echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

COPY assets/ /opt/resource/

FROM main as testing

RUN set -eux; \
    gem install rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-galaxy; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-playbook; \
    cp /usr/local/bin/mockleton /usr/bin/ssh-add;

COPY . /resource/

WORKDIR /resource
RUN rspec

FROM main
