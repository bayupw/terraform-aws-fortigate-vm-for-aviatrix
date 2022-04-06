# Terraform AWS Module - Fortigate VM for Aviatrix

Terraform module to deploy Fortigate VM instance into existing Transit VPC for Aviatrix Firenet integration
Includes a bootstrap to configure allow all policy for east-wast (traffic nspection) and north-south (egress)

## Usage with minimal customisation with default admin password: Aviatrix123#

```hcl
module "fortigate_vm_1" {
  source  = "bayupw/fortigate-vm-for-aviatrix/aws"
  version = "1.0.0"

  vpc_id            = "vpc-0a1b2c3d4e"
  egress_subnet_id  = "subnet-0a1b2c3d4e"
  lan_subnet_id     = "subnet-1b2c3d4e5f"
}
```

## Usage with customisation on firewall instance details

```hcl
module "fortigate_vm_1" {
  source  = "bayupw/fortigate-vm-for-aviatrix/aws"
  version = "1.0.0"

  vpc_id            = "vpc-0a1b2c3d4e"
  egress_subnet_id  = "subnet-0a1b2c3d4e"
  lan_subnet_id     = "subnet-1b2c3d4e5f"
  az_suffix         = "a"
  fw_instance_type  = "t3.small"
  fw_instance_name  = "fortigate-vm"
  fw_admin_password = "Aviatrix123#"
  key_name          = "ec2-keypair"
}
```

## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/bayupw/terraform-aws-fortigate-vm-for-aviatrix/issues/new) section.

## License

Apache 2 Licensed. See [LICENSE](https://github.com/bayupw/terraform-aws-fortigate-vm-for-aviatrix/tree/master/LICENSE) for full details.
