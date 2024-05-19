# Packer - New Relic (AMI)

[Packer templates](https://developer.hashicorp.com/packer/docs/templates) for creating deployable OS images with the New Relic Infrastructure agent installed.

## Usage

To create the AMI, run the following command against a `.pkr.hcl` file:

```sh
packer init ./al2023_x86_64.pkr.hcl
packer build -var "region=us-west-2" ./al2023_x86_64.pkr.hcl
```
