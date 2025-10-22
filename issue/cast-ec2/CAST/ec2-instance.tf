resource "aws_instance" "cast_ec2" {
  # TODO changed coutn to 0 to 
  # count                       = 0
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.aft_default_customization_compatibility.id]
  subnet_id                   = local.default_vpc_subnet_id
  associate_public_ip_address = var.enable_public_ip

  ebs_optimized = var.enable_ebs_optimization

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
    encrypted             = var.enable_encryption
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "cast-ec2-root-volume"
      Type = "Root"
    })
  }

  ebs_block_device {
    device_name = var.data_volume_device_name
    volume_type = var.data_volume_type
    volume_size = var.data_volume_size
    iops        = var.data_volume_iops
    throughput  = var.data_volume_throughput
    encrypted   = var.enable_encryption

    tags = merge(local.common_tags, {
      Name = "cast-ec2-data-volume"
      Type = "Data"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.app}-${local.env}-ec2"
    Type = "EC2-Instance"
  })
}
