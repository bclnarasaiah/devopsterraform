provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
}

locals {
    common_tags = {
        costcenter = 8080
        owner = "bcl"
        environment = "production"
    }
}

resource "aws_vpc" "vpc1" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = var.vpc_name
        costcenter = local.common_tags.costcenter
        owner = local.common_tags.owner
        environment = local.common_tags.environment
    }
    depends_on = [
        aws_s3_bucket.bucket1
    ]
}

resource "aws_flow_log" "example" {
  log_destination      = "${aws_s3_bucket.bucket1.arn}"
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = "${aws_vpc.vpc1.id}"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc1.id}"
	tags = {
        Name = "${aws_vpc.vpc1.tags.Name}-igw"
        costcenter = local.common_tags.costcenter
        owner = local.common_tags.owner
        environment = local.common_tags.environment
    }
}

resource "aws_subnet" "subnet1-public" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = var.subnet1_cidr
    availability_zone = "us-east-1a"
    tags = {
        Name = "Subnet-1"
        costcenter = local.common_tags.costcenter
        owner = local.common_tags.owner
        environment = local.common_tags.environment
    }
}

resource "aws_subnet" "subnet2-public" {
    vpc_id = "${aws_vpc.vpc1.id}"
    cidr_block = var.subnet2_cidr
    availability_zone = "us-east-1a"
    tags = "${merge(local.common_tags,map("Name", "Subnet-002"))}"
}

resource "aws_s3_bucket" "bucket1" {
  bucket = var.bucketname
  tags = {
        Name = var.bucketname
        costcenter = local.common_tags.costcenter
        owner = local.common_tags.owner
        environment = local.common_tags.environment
    }
}