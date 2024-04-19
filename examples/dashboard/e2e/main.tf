terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  alias = "eu-central-1"

  region = "eu-central-1"
}

provider "aws" {
  alias = "eu-west-2"

  region = "eu-west-2"
}

module "eu-central-1" {
  source = "./modules/script"

  ami_id               = var.ami_id[data.aws_region.current.name]
  instances_count      = var.instances_count / 2
  instance_type        = var.instance_type
  security_group_id    = var.security_group_id[data.aws_region.current.name]
  subnet_id            = var.subnet_id[data.aws_region.current.name]
  sut_name             = var.sut_name
  key_name             = var.key_name
  private_key_location = var.private_key_location

  testrun_name    = var.testrun_name
  testrun_id      = var.testrun_id
  test_origin     = var.test_origin
  benchmark_id    = var.benchmark_id
  kenbench_token = var.kenbench_token
  kenbench_uri   = var.kenbench_uri

  gen_load = false
  rate     = var.rate
  conns    = var.conns
  duration = var.duration
  pg_pass  = var.pg_pass
  pg_host  = var.pg_host
  mp_token = var.mp_token
  mp_uri   = var.mp_uri

  depends_on = [
    module.setup_infra.ready,
  ]

  providers = {
    aws = aws.eu-central-1
  }
}

module "eu-west-2" {
  source = "./modules/script"

  ami_id               = var.ami_id[data.aws_region.current.name]
  instances_count      = var.instances_count / 2
  instance_type        = var.instance_type
  security_group_id    = var.security_group_id[data.aws_region.current.name]
  subnet_id            = var.subnet_id[data.aws_region.current.name]
  sut_name             = var.sut_name
  key_name             = var.key_name
  private_key_location = var.private_key_location

  testrun_name    = var.testrun_name
  testrun_id      = var.testrun_id
  test_origin     = var.test_origin
  benchmark_id    = var.benchmark_id
  kenbench_token = var.kenbench_token
  kenbench_uri   = var.kenbench_uri

  gen_load = true
  rate     = var.rate
  conns    = var.conns
  duration = var.duration
  pg_pass  = var.pg_pass
  pg_host  = var.pg_host
  mp_token = var.mp_token
  mp_uri   = var.mp_uri

  depends_on = [
    module.setup_infra.ready,
  ]

  providers = {
    aws = aws.eu-west-2
  }
}