# Tech Case: Automated deployment of virtual machines using Packer, Terragrunt & Ansible. Orchestrated by GitLab CI

# Get started

docker build --pull --rm -f "misc-helpers\vre-build-env.Dockerfile" -t techcasetommydejong:latest "misc-helpers"
docker run --rm -it -v ${PWD}:/usr/project techcasetommydejong:latest
source /usr/azure_credentials.sh
terragrunt run-all apply --terragrunt-non-interactive

For Packer build:

cd windows/
packer init/validate/build .