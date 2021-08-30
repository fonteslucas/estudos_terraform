variable "vpcid" {
  type = string
}

variable "igwid" {
  type = string 
}

variable "subnetida" {
  type = string
}

variable "subnetidb" {
  type = string
}

resource "aws_route_table" "myterraform_public_rtb" {
  vpc_id = var.vpcid
  tags = {
      "Name" = "myterraform_public_rtb"
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

resource "aws_route" "internet_route" {
  route_table_id            = aws_route_table.myterraform_public_rtb.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = var.igwid
  depends_on                = [aws_route_table.myterraform_public_rtb]
}   

resource "aws_route_table_association" "az-a" {
  subnet_id      = var.subnetida
  route_table_id = aws_route_table.myterraform_public_rtb.id
}

resource "aws_route_table_association" "az-b" {
  subnet_id      = var.subnetidb
  route_table_id = aws_route_table.myterraform_public_rtb.id
}

output "myterraform_public_rtb_id" {
    value = aws_route_table.myterraform_public_rtb.id
}