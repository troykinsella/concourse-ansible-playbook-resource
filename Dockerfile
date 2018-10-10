FROM ansible/ansible:ubuntu1604 as main

RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      jq; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*;

COPY assets/* /opt/resource/


FROM main as testing

RUN set -eux; \
    apt-get update -y; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ruby; \
    apt-get clean all; \
    rm -rf /var/lib/apt/lists/*; \
    gem install \
      rspec;

COPY . /resource/

RUN set -eux; \
    cd /resource; \
    rspec


FROM main
