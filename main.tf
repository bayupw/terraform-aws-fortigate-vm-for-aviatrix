# ---------------------------------------------------------------------------------------------------------------------
# Launch Firewall Instance
# ---------------------------------------------------------------------------------------------------------------------

data "aws_region" "current" {}

# Retrieve subnet details for Port2 | LAN | transit-dmz-firewall
data "aws_subnet" "lan_subnet" {
  id = var.lan_subnet_id
}

# Create eni for Port1 | WAN | Egress
resource "aws_network_interface" "port1_egress" {
  description = "${var.fw_instance_name}-port1-egress"
  subnet_id   = var.egress_subnet_id

  tags = {
    Name = "${var.fw_instance_name}-port1-egress"
  }
}

# Create eni for Port2 | LAN | transit-dmz-firewall
resource "aws_network_interface" "port2_lan" {
  description       = "${var.fw_instance_name}-port2-lan"
  subnet_id         = var.lan_subnet_id
  source_dest_check = false

  tags = {
    Name = "${var.fw_instance_name}-port2-lan"
  }
}

# Create Security Group for Port1 | WAN | Egress
resource "aws_security_group" "port1_egress_sg" {
  name        = "${var.fw_instance_name}-port1-egress"
  description = "Allow any"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.fw_instance_name}-port1-egress"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# Create Security Group for Port2 | LAN | transit-dmz-firewall
resource "aws_security_group" "port2_lan_sg" {
  name        = "${var.fw_instance_name}-port2-lan"
  description = "Allow any"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.fw_instance_name}-port2-lan"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

# Attach Port1 | WAN | Egress to the relevant Security Group
resource "aws_network_interface_sg_attachment" "egress_sg_attachment" {
  depends_on           = [aws_network_interface.port1_egress]
  security_group_id    = aws_security_group.port1_egress_sg.id
  network_interface_id = aws_network_interface.port1_egress.id
}

# Attach Port2 | LAN | transit-dmz-firewall to the relevant Security Group
resource "aws_network_interface_sg_attachment" "lan_sg_attachment" {
  depends_on           = [aws_network_interface.port2_lan]
  security_group_id    = aws_security_group.port2_lan_sg.id
  network_interface_id = aws_network_interface.port2_lan.id
}

# Create single fortigate-vm EC2 instance
resource "aws_instance" "this" {
  ami               = var.license_type == "byol" ? var.fgt_byol_ami[data.aws_region.current.name] : var.fgt_payg_ami[data.aws_region.current.name]
  instance_type     = var.fw_instance_type
  availability_zone = "${data.aws_region.current.name}${var.az_suffix}"
  key_name          = var.key_name
  
  # Apply bootstrap.sh
  user_data = templatefile("${path.module}/bootstrap.sh",
    {
      "fw_admin_password" = var.fw_admin_password
      "lan_gateway_ip"    = cidrhost(data.aws_subnet.lan_subnet.cidr_block, 1)
    }
  )

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "standard"
  }

  network_interface {
    network_interface_id = aws_network_interface.port1_egress.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.port2_lan.id
    device_index         = 1
  }

  tags = {
    Name = "${var.fw_instance_name}"
  }
}

resource "aws_eip" "this" {
  vpc               = true
  network_interface = aws_network_interface.port1_egress.id

  tags = {
    Name = "FortiGate-EIP@${var.fw_instance_name}"
  }

  depends_on        = [aws_instance.this]
}

/* data "template_file" "FortiGate" {
  template = file("${var.bootstrap-fgtvm}")
  vars = {
    type         = "${var.license_type}"
    license_file = "${var.license}"
    adminsport   = "${var.adminsport}"
  } 
} */