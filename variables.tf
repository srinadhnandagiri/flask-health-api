variable "project" { }

variable "credentials_file" { }

variable "vpc_name" {
  default = "flask-api-vpc"
 }
variable "subnet_name" {
  default = "flask-api-subnet"
 }
variable "cidr_range" { }
variable "region" {
  default = "asia-south1"
}

variable "zone" {
  default = "asia-south1-c"
}

variable "vm_machine_type" {
  default = "n1-standard-1"
}
variable "disk_size" {
  default = 10
}

variable "vm_name" {
  default = "flask-health-api-vm"
 }
variable "ig_name" {
  default = "flask-api-ig"
}
variable "vm_image" {
  default = "debian-cloud/debian-11"
}
variable "health_api_port" {
  default = 8080
}
variable "network_tag" {
  default = "lb-access"
}
