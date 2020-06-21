variable "region" {
}

variable "vpc-cidr" {
}

variable "subnet-cidr-public" {
}

# for the purpose of this exercise use the default key pair on your local system
variable "public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "default_tags" { 
    type = "map" 
    default = { 
        Name = "SimonEmms"
        Owner = "Simon Emms"
        Project = "Tech Test"
  } 
}