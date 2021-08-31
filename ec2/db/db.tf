variable "ec2dbname" {
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

variable "dbsg" {
    type = string
}

resource "aws_instance" "db" {
    ami = var.amiid
    instance_type = var.instancetype
    vpc_security_group_ids = [var.dbsg]
    user_data = file("./web/server-script.sh")
    iam_instance_profile = "EC2Role+SSM"
    subnet_id = var.subnetid
    ebs_block_device {
      device_name = "/dev/xvdf"
      volume_size = 60
      volume_type = "gp3"
    }
    ebs_block_device {
      device_name = "/dev/xvdg"
      volume_size = 60
      volume_type = "gp3"
    }
    tags = {
      Name = var.ec2dbname
      "auto-delete" = "never"
      "auto-stop" = "no"
    }
}

output "privatedns" {
    value = aws_instance.db.private_dns
}