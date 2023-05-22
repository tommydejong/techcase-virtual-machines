FROM golang:1.16.2-alpine

RUN apk update && apk add --virtual=build --no-cache \
      git \
      bash \
      perl \
      unzip \
      curl \
      build-base \
      make \
      ca-certificates
RUN   curl -L "https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip" > terraform.zip && unzip terraform.zip && rm terraform.zip && chmod +x terraform && mv terraform /usr/bin/
RUN   curl -L "$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | grep -o -m 1 -E "https://.+?-linux-amd64")" > terraform-docs && chmod +x terraform-docs && mv terraform-docs /usr/bin/
RUN   curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && mv tflint /usr/bin/
RUN   curl -L "$(curl -s https://api.github.com/repos/tfsec/tfsec/releases/latest | grep -o -E "https://.+?tfsec-linux-amd64")" > tfsec && chmod +x tfsec && mv tfsec /usr/bin/

RUN   pip3 install azure-cli pre-commit --ignore-installed distlib \
      && mkdir /pre-commit && \
      cd /pre-commit && \
      git init . && \
      pre-commit install