# Packer scripts

This repo contains the Packer scripts for creating the OS images used for the VRE service. With Packer, we can create our own OS images with security settings and patches we require by taking a cloud's base OS image and post-processing these. Also, we can automatically periodically recreate these images so they contain the latest official updates. 

This is exactly the reason why we use Packer instead of Ansible or basic images: with Packer, we can ensure that every VRE we deploy uses an image that follows our security guidelines. Also, we can archive the images so that research environments can be easily retrieved at a later time.

Currently, the Packer scripts in this repo allow us to create the following images:
* Windows 10 Desktop on Azure
* Ubuntu on Azure **and** AWS

We do not support Windows 10 Desktop on AWS at this point, since AWS does not have a Windows 10 base image (only a Windows Server base image) and due to licensing difficulties.
For the Ubuntu distribution we use base images provided by Canonical, official publisher of Ubuntu.

## How it works

Packer uses the concepts of sources and builders containing post-processors to separate logical steps in the process. In short, it creates a temporary virtual machine based on the source image provided. From there, the build stage is started where Packer can run multiple post-processors (such as Bash, Powershell, Ansible commands) in order. After these steps complete, the image is packaged and written to a new cloud image that can be used for VRE's, and the temporary VM is removed.

## Repository setup

The repository is split in two folders, `windows` and `linux`.
In the `linux` folder there are three variable files:
* `aws-vars.pkr.hcl` for AWS-specific variables, such as the AWS region (defaults to *eu-central-1*) and EC2 instance size for creating the image (defaults to *t2.micro*)