terraform {
  cloud {
    organization = "_FM_"
    workspaces {
      tags = ["kiratech-test"]
    }
  }
}