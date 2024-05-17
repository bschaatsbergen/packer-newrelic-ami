packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

# Retrieve the New Relic API key from AWS Secrets Manager
data "amazon-secretsmanager" "newrelic_api_key" {
  name   = "newrelic/apikey"
  region = "us-west-2"
}

# Create a new AMI based on the latest Amazon Linux 2023 AMI
source "amazon-ebs" "al2023_x86_64_source" {
  ami_name        = "newrelic-al2023-{{timestamp}}"
  ami_description = "Amazon Linux 2023 with New Relic Infrastructure Agent"

  region        = "us-west-2"
  instance_type = "t2.micro"
  source_ami_filter {
    filters = {
      image-id            = "ami-01cd4de4363ab6ee8" # Amazon Linux 2023 (64-bit (x86_64), uefi-preferred) 
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "newrelic-al2023"

  sources = [
    "source.amazon-ebs.al2023_x86_64_source"
  ]

  provisioner "shell" {
    environment_vars = [
      "NRIA_LICENSE_KEY=${data.amazon-secretsmanager.newrelic_api_key.secret_string}",
    ]
    inline = [
      "echo \"license_key: $NRIA_LICENSE_KEY\" | sudo tee -a /etc/newrelic-infra.yml &> /dev/null",
      "sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/amazonlinux/2023/x86_64/newrelic-infra.repo",
      "sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'",
      "sudo yum install newrelic-infra -y",
    ]
  }
}
