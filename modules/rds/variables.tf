variable "database_security_group" {}
variable "private_data_subnet_az1_id" {}
variable "private_data_subnet_az2_id" {}
variable "database_username" {}
variable "database_password" {}
variable "database-subnets" {
    default = "manogna-wesbite-db-subnet"
}
variable "database_name" {
    default = "testdb"
}
