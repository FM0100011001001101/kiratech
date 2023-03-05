
module "master" {
  source = "./modules/master"
}

output "subnet_name" {
    value = module.master.subnet_name
    sensitive = false
}

output "rsg_name" {
    value = module.master.rsg_name
    sensitive = false
}

output "rsg_location" {
    value = module.master.rsg_location
    sensitive = false
}

module "worker" {
  source = "./modules/worker"
  depends_on = [module.master]

  rsg_name = module.master.rsg_name
  rsg_location = module.master.rsg_location
  subnet_name = module.master.subnet_name
}