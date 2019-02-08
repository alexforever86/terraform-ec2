provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_instance" "app" {
  count = "${var.ec2_count}"

  ami             = "${var.ec2_ami}"
  availability_zone = "us-east-1a"
  instance_type   = "${var.ec2_type}"
  key_name        = "my_key_pair"
  security_groups = ["${aws_security_group.ec2.name}"]

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "sudo apt update",
      "sudo apt install -y nginx",
    ]

      connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./my_key_pair.pem")}"
      agent       = false
    }
  }

  tags {
    Name    = "${var.project}"
    Project = "${var.project}"
  }
}

resource "aws_elb" "frontend" {
  name = "frontend-load-balancer"
  availability_zones = ["us-east-1a"]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances = ["${aws_instance.app.*.id}"]
  security_groups = ["${aws_security_group.elb.id}"]

  tags {
    Project = "${var.project}"
  }
}

resource "aws_security_group" "elb" {
  name            = "elb_security_group"
  description     = "Allow all inbound traffic"


  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Project = "${var.project}"
    Name    = "${var.project}_elb"
  }
}

resource "aws_security_group" "ec2" {
  name        = "ec2 security group"
  description = "Allow all inbound traffic"


  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Project = "${var.project}"
    Name    = "${var.project}_ec2"
  }
}

output "domain" {
  value = "${aws_elb.frontend.dns_name}"
}
