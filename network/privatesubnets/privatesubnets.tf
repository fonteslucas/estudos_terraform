variable "vpcid" {
  type = string
}

resource "aws_subnet" "myterraform_privatesubnet_az-a" {
  vpc_id     = var.vpcid
  cidr_block = "172.31.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
      "Name" = "myterraform_privatesubnet_az-a"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_subnet" "myterraform_privatesubnet_az-b" {
  vpc_id     = var.vpcid
  cidr_block = "172.31.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
      "Name" = "myterraform_privatesubnet_az-b"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

output "myterraform_privatesubnet_az_a_id" {
    value = aws_subnet.myterraform_privatesubnet_az-a.id
}

output "myterraform_privatesubnet_az_b_id" {
    value = aws_subnet.myterraform_privatesubnet_az-b.id
}