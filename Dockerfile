FROM ubuntu:xenial as main

RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      python \
      python-pip \
      wget; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*; \
    pip install \
      ansible \
      boto; \
    mkdir -p /etc/ansible; \
    echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

COPY assets/ /opt/resource/


FROM main as testing

RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ruby; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*; \
    gem install \
      rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-galaxy; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-playbook;

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec


FROM main
