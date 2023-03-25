```hcl

provider "aws" {
  region = "us-east-1"
}

module "docker_instance" {
    source = "MehmetAliYZC/docker-instance/aws"
    key_name = "clarusway"
}
```