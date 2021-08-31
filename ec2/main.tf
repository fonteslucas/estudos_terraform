provider "aws" {
    region = "us-east-1"
}

module "sgweb" {
    source = "./sgweb"
    vpcid = "vpc-0f3b63ab9a0d9393f"
}

module "sgdb" {
    depends_on = [
      module.sgweb
    ]
    source = "./sgdb"
    vpcid = "vpc-0f3b63ab9a0d9393f"
    sgweb = module.sgweb.sg_id
}

module "db" {
    depends_on = [
      module.sgdb
    ]
    source = "./db"
    subnetid = "subnet-057b6be992384a09b"
    amiid = "ami-0c2b8ca1dad447f8a"
    ec2dbname = "MyDBServer"
    dbsg = module.sgdb.sg_id
}

module "web" {
    depends_on = [
      module.sgweb
    ]
    source = "./web"
    subnetid = "subnet-05cffadb0e88b1a58" 
    amiid = "ami-0c2b8ca1dad447f8a"
    ec2name = "MyWebServer"
    sgweb = module.sgweb.sg_id
}



output "PrivateIP" {
    value = module.db.privatedns
}

output "PublicIP" {
    value = module.web.publicip
}