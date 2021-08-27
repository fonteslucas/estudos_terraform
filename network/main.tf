provider "aws" {
    region = "us-east-1"
}

module "vpc" {
  source = "./vpc"
  vpcname = "myterraform_vpc"
}

module "publicsubnets" {
  source = "./publicsubnets"
  vpcid = module.vpc.myterraform_vpc_id
}

module "publicrtb" {
  source = "./publicrtb"
  vpcid = module.vpc.myterraform_vpc_id
  igwid = module.vpc.myterraform_igw_id
  subnetida = module.publicsubnets.myterraform_publicsubnet_az_a_id
  subnetidb = module.publicsubnets.myterraform_publicsubnet_az_a_id
}

module "privatesubnets" {
  source = "./privatesubnets"
  vpcid = module.vpc.myterraform_vpc_id
}

module "privatertb" {
  source = "./privatertb"
  vpcid = module.vpc.myterraform_vpc_id
  natgwid = module.publicsubnets.myterraform_nat_gw_id
  pvt_subnetid_a = module.privatesubnets.myterraform_privatesubnet_az_a_id
  pvt_subnetid_b = module.privatesubnets.myterraform_privatesubnet_az_b_id
}