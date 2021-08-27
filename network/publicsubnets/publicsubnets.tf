variable "vpcid" {
  type = string
}

resource "aws_subnet" "myterraform_publicsubnet_az-a" {
  vpc_id     = var.vpcid
  cidr_block = "172.31.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
      "Name" = "myterraform_publicsubnet_az-a"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_subnet" "myterraform_publicsubnet_az-b" {
    vpc_id     = var.vpcid
    cidr_block = "172.31.2.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true
    tags = {
      "Name" = "myterraform_publicsubnet_az-b"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_nat_gateway" "myterraform_natgw" {
    subnet_id = aws_subnet.myterraform_publicsubnet_az-a.id
    allocation_id = aws_eip.myterraform_eip_ntgw.id
    tags = {
      Name = "myterraform_natgw"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_eip" "myterraform_eip_ntgw" {
    tags = {
      Name = "myterraform_eip_ntgw"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

output "myterraform_publicsubnet_az_a_id" {
    value = aws_subnet.myterraform_publicsubnet_az-a.id
}

output "myterraform_publicsubnet_az_b_id" {
    value = aws_subnet.myterraform_publicsubnet_az-b.id
}

output "myterraform_nat_gw_id" {
    value = aws_nat_gateway.myterraform_natgw.id
}