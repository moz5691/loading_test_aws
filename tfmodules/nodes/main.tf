# setup rsa key for accessing
resource "aws_key_pair" "deployer" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.temp.public_key_openssh

}

resource "tls_private_key" "temp" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# setup security groups
resource "aws_security_group" "nodes" {
  name        = "locust-nodes"
  description = "Allow all inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_cross_comms" {
  security_group_id        = aws_security_group.nodes.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nodes.id
}

# setup master locust stack via cloudformation as we can load large files onto the instances.
resource "aws_instance" "master" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.nodes.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "${var.name}-master"
  }

  # Depedning on environment, "file" option is provisioner may not work.
  # Your network may not allow transfer a file to cloud from your local machine.
  # You may uncomment and comment out "cat <<EOF > ..." in "remote-exec" if you can use "file" option.

//  provisioner "file" {
//    source      = "${path.module}/supervisord.conf"
//    destination = "supervisord.conf"
//  }

//  provisioner "file" {
//    source      = "locustfile.py"
//    destination = "locustfile.py"
//  }

  # AWS Amazon Linux AMI - if you choose a different type of AMI, change accordingly.
  provisioner "remote-exec" {
    inline = [
      "cat <<EOF > locustfile.py\n${file("locustfile.py")}\nEOF",
      "cat <<EOF > supervisord.conf\n${file("${path.module}/supervisord.conf")}\nEOF",
      "sudo yum update -y",
      "sudo yum install python36 -y",
      "sudo python36 -m pip install --upgrade pip",
      "echo \"command=${var.locust_command} --master\" >> supervisord.conf",
      "sudo mv supervisord.conf /etc/supervisord.conf",
      "sudo python36 -m pip install locustio",
      "sudo python36 -m pip install supervisor",
      "sudo /usr/local/bin/supervisord",
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.temp.private_key_pem
  }
}

resource "aws_instance" "slave" {
  count                  = var.number_of_workers
  ami                    = var.ami
  instance_type          = var.worker_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.nodes.id]
  subnet_id              = var.subnet_id

  tags = {
    Name = "${var.name}-slave"
  }

  # Depedning on environment, "file" option is provisioner may not work.
  # Your network may not allow transfer a file to cloud from your local machine.
  # You may uncomment and comment out "cat <<EOF > ..." in "remote-exec" if you can use "file" option.

//  provisioner "file" {
//    source      = "${path.module}/supervisord.conf"
//    destination = "supervisord.conf"
//  }
//
//  provisioner "file" {
//    source      = "locustfile.py"
//    destination = "locustfile.py"
//  }

  # AWS Amazon Linux AMI - if you choose a different type of AMI, change accordingly.
  provisioner "remote-exec" {
    inline = [
      "cat <<EOF > locustfile.py\n${file("locustfile.py")}\nEOF",
      "cat <<EOF > supervisord.conf\n${file("${path.module}/supervisord.conf")}\nEOF",
      "sudo yum update -y",
      "sudo yum install python36 -y",
      "sudo python36 -m pip install --upgrade pip",
      "echo \"command=${var.locust_command} --slave --master-host=${aws_instance.master.private_ip}\" >> supervisord.conf",
      "sudo mv supervisord.conf /etc/supervisord.conf",
      "sudo python36 -m pip install locustio",
      "sudo python36 -m pip install supervisor",
      "sudo /usr/local/bin/supervisord",
    ]
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.temp.private_key_pem
  }
}
