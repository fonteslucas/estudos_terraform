variable "vpcid" {
    type = string
}

variable "sgweb" {
    type = string
}

resource "aws_security_group" "db_traffic" {
    name = "Allow Database Traffic"
    vpc_id = var.vpcid
    ingress {
        to_port = 3306
        from_port = 3306
        protocol = "tcp"
        security_groups = [var.sgweb]
    }

    egress {
        to_port = 0
        from_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

output "sg_name" {
    value = aws_security_group.db_traffic.name
}

output "sg_id" {
    value = aws_security_group.db_traffic.id
}