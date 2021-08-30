variable "vpcname" {
  type = string
}

resource "aws_vpc" "myterraform_vpc" {
    cidr_block = "172.31.0.0/16"
    enable_dns_hostnames = true
    tags = {
      "Name" = var.vpcname
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_internet_gateway" "myterraform_igw" {
  vpc_id = aws_vpc.myterraform_vpc.id
  tags = {
      Name = "myterraform_igw"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

output "myterraform_vpc_id" {
    value = aws_vpc.myterraform_vpc.id
}

output "myterraform_igw_id" {
    value = aws_internet_gateway.myterraform_igw.id
}