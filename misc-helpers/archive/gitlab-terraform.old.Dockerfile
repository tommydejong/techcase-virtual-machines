FROM registry.gitlab.com/gitlab-org/terraform-images/stable:latest

RUN apk update && apk add --virtual=build --no-cache \
      curl \
      bash \
      unzip \
      curl \
      ansible \
      gcc \
      libffi-dev \
      musl-dev \
      openssl-dev \
      py3-pip \
      python3-dev \
      perl \
      build-base \
      make \
      ca-certificates
COPY terraform-ansible-inventory.py /usr/terraform.py
RUN  chmod +x /usr/terraform.py
RUN  pip3 install azure-cli
RUN  ansible-galaxy collection install ansible.windows
RUN  apk del --purge build