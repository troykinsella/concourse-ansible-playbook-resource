FROM ubuntu:bionic as main

RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      git \
      openssh-client \
      python3 \
      python3-apt \
      python3-pip \
      rsync \
      ruby \
      wget; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*; \
    pip3 install --no-cache-dir \
      ansible \
      pywinrm>=0.3.0 \
      boto; \
    mkdir -p /etc/ansible; \
    echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts

COPY assets/ /opt/resource/


FROM main as testing

RUN set -eux; \
    gem install \
      rspec; \
    wget -q -O - https://raw.githubusercontent.com/troykinsella/mockleton/master/install.sh | bash; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-galaxy; \
    cp /usr/local/bin/mockleton /usr/local/bin/ansible-playbook; \
    cp /usr/local/bin/mockleton /usr/bin/ssh-add;

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec


FROM main
