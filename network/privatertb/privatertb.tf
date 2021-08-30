variable "vpcid" {
  type = string
}

variable "natgwid" {
  type = string
}

variable "pvt_subnetid_a" {
  type = string
}

variable "pvt_subnetid_b" {
  type = string
}

resource "aws_route_table" "myterraform_private_rtb" {
  vpc_id = var.vpcid
  tags = {
      "Name" = "myterraform_private_rtb"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_route" "private_internet_route" {
  route_table_id            = aws_route_table.myterraform_private_rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = var.natgwid
  depends_on                = [aws_route_table.myterraform_private_rtb]
}

resource "aws_route_table_association" "az-a" {
  subnet_id      = var.pvt_subnetid_a
  route_table_id = aws_route_table.myterraform_private_rtb.id
}

resource "aws_route_table_association" "az-b" {
  subnet_id      = var.pvt_subnetid_b
  route_table_id = aws_route_table.myterraform_private_rtb.id
}