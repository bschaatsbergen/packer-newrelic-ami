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

  # Write a templated New Relic Infrastructure Agent (NRIA) configuration
  provisioner "file" {
    destination = "/tmp/newrelic-infra.yml"
    content = templatefile("${path.root}/newrelic-infra.pkrtpl.hcl", {
      license_key = data.amazon-secretsmanager.newrelic_api_key.secret_string,
    })
  }

  # Move the NRIA configuration to /etc/newrelic-infra/
  provisioner "shell" {
    inline = [
      "sudo mkdir -p /etc/newrelic-infra",
      "sudo mv /tmp/newrelic-infra.yml /etc/newrelic-infra/newrelic-infra.yml",
    ]
  }

  # Install the NRIA (x86_64)
  provisioner "shell" {
    inline = [
      "sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/amazonlinux/2023/x86_64/newrelic-infra.repo",
      "sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'",
      "sudo yum install newrelic-infra -y",
    ]
  }

  # Install the Amazon CloudWatch Agent
  provisioner "shell" {
    inline = [
      "sudo yum install -y amazon-cloudwatch-agent",
    ]
  }

  # Write the Amazon CloudWatch Agent configuration
  provisioner "file" {
    destination = "/tmp/amazon-cloudwatch-agent-config.json"
    content     = file("${path.root}/amazon-cloudwatch-agent-config.json")
  }

  # Move the Amazon CloudWatch Agent configuration
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/amazon-cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json",
    ]
  }

  # Start the Amazon CloudWatch Agent
  provisioner "shell" {
    inline = [
      "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s",
    ]
  }
}
