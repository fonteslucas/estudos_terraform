variable "ec2name" {
  type = string
}

variable "subnetid" {
  type = string
}

variable "instancetype" {
  type = string
  default = "m5.large"
}

variable "amiid" {
  type = string
}

variable "sgweb" {
  type = string
}

resource "aws_instance" "web" {
    ami = var.amiid
    instance_type = var.instancetype
    vpc_security_group_ids = [var.sgweb]
    user_data = file("./web/server-script.sh")
    subnet_id = var.subnetid
    iam_instance_profile = "EC2Role+SSM"
    tags = {
      Name = var.ec2name
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

output "publicip" {
    value = aws_instance.web.public_ip
}