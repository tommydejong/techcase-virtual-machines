FROM alpine:3.14

# Set binary versions for the different tools here
ENV AZURE_CLI_VERSION 2.29.0
ENV ANSIBLE_VERSION 4.7.0
ENV TERRAFORM_VERSION 1.0.9
ENV TERRAGRUNT_VERSION 0.35.2
ENV PACKER_VERSION 1.8.1

# Set some env variables that are normally set in GitLab
ENV TERRAGRUNT_DISABLE_INIT false
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_TF_BIN terragrunt
ENV PROJECT_ROOT /usr/project

# Install needed packages and cleanup the image
RUN apk update && apk add --virtual=build --no-cache \
    curl \
    bash \
    unzip \
    curl \
    git \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    py3-pip \
    python3-dev \
    perl \
    build-base \
    make \
    ca-certificates \
    openssh-client \
    libc6-compat && \
    rm -rf /var/cache/apk/*

# Install pip, and shyaml to parse YAML values
# Install Azure CLI using pip
RUN pip3 install --no-cache-dir --upgrade pip shyaml && \
    pip3 install --no-cache-dir azure-cli==$AZURE_CLI_VERSION

# Install Ansible from pip, repository version is outdated
RUN pip install --no-cache-dir ansible==$ANSIBLE_VERSION

# Copy helper scripts
COPY create_az_snapshot.sh /usr/create_az_snapshot.sh
COPY upload_vre_config_blob.sh /usr/upload_vre_config_blob.sh
COPY azure_credentials.sh /usr/azure_credentials.sh
COPY run_ansible.sh /usr/run_ansible.sh

# Copy dynamic inventory script for Ansible provider for Terraform
COPY terraform-ansible-inventory.py /usr/terraform.py
RUN  chmod +x /usr/terraform.py

# Ensure python command symlink to prevent issues in Azure images
RUN  if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi 

# Install azcopy for Ansible
RUN curl --location --output azcopy.tar.gz --url https://aka.ms/downloadazcopy-v10-linux && tar -xzf azcopy.tar.gz --strip-components=1 && mv azcopy /usr/bin/

# Install Terraform
RUN curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" > terraform.zip && unzip terraform.zip && rm terraform.zip && chmod +x terraform && mv terraform /usr/bin/

# Install Terragrunt
RUN curl -L "$(curl -s https://api.github.com/repos/gruntwork-io/terragrunt/releases/tags/v${TERRAGRUNT_VERSION} | grep -o -m 1 -E "https://.+?_linux_amd64")" > terragrunt && chmod +x terragrunt && mv terragrunt /usr/bin/

# Install Packer
RUN curl -L "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" > packer.zip && unzip packer.zip && rm packer.zip && chmod +x packer && mv packer /usr/bin/

WORKDIR /usr/project