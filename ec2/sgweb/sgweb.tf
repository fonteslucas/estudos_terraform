variable "ingress" {
    type = list(number)
    default = [80,443]
}

variable "vpcid" {
    type = string
}

resource "aws_security_group" "web_traffic" {
    name = "Allow Web Traffic"
    vpc_id = var.vpcid
    dynamic "ingress" {
        iterator = port
        for_each = var.ingress
        content {
            from_port = port.value
            to_port = port. value
            protocol = "TCP"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    egress {
        to_port = 0
        from_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    } 
}

output "sg_name" {
    value = aws_security_group.web_traffic.name
}

output "sg_id" {
    value = aws_security_group.web_traffic.id
}