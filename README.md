# Packer - New Relic (AMI)

[Packer templates](https://developer.hashicorp.com/packer/docs/templates) for creating deployable OS images with the New Relic Infrastructure agent installed.

## Usage

To create the AMI, run the following command against a `.pkr.hcl` file:

```sh
packer init al2023_x86_64.pkr.hcl
packer build al2023_x86_64.pkr.hcl
```

If you're using GitHub Actions, you can use the [setup-packer](https://github.com/hashicorp/setup-packer) action to create the AMI:

```yaml
steps:
  - name: Setup `packer`
    uses: hashicorp/setup-packer@main
    id: setup
    with:
      version: "latest"

  - name: Initialize Packer
    id: init
    run: "packer init ./al2023_x86_64.pkr.hcl"

  - name: Validate Packer template
    id: validate
    run: "packer validate ./al2023_x86_64.pkr.hcl"

  - name: Create AMI
    run: packer build -color=false -on-error=abort ./al2023_x86_64.pkr.hcl
```
