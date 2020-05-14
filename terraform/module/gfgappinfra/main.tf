resource "aws_vpc" "gfgnetwork" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "net1" {
  vpc_id                  = aws_vpc.gfgnetwork.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
}


resource "aws_subnet" "net2" {
  vpc_id                  = aws_vpc.gfgnetwork.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2b"
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = aws_vpc.gfgnetwork.id
}

resource "aws_route_table" "rtb1" {
  vpc_id = aws_vpc.gfgnetwork.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw1.id
  }
}

resource "aws_route_table_association" "my_vpc_us_west_2a_public" {
  subnet_id      = aws_subnet.net1.id
  route_table_id = aws_route_table.rtb1.id
}

resource "aws_route_table_association" "my_vpc_us_west_2b_public" {
  subnet_id      = aws_subnet.net2.id
  route_table_id = aws_route_table.rtb1.id
}

resource "aws_instance" "web" {
  ami                    = "ami-0d6621c01e8c2de2c"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.web_key.key_name
  subnet_id              = aws_subnet.net1.id
  vpc_security_group_ids = [aws_security_group.allow_web_access_to_ec2.id, aws_security_group.allow_ssh_access_to_ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    volume_size = 16
  }
}

resource "tls_private_key" "web_priv_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_key" {
  key_name   = "web_key"
  public_key = tls_private_key.web_priv_key.public_key_openssh
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.web_role.name
}

resource "aws_iam_role" "web_role" {
  name = "web_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "allow_access_to_param_store" {
  name        = "allow_access_to_param_store"
  description = "Allow access to param store"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameter"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ssm:*"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "allow_access_to_kms" {
  name        = "allow_access_to_kms"
  description = "Allow access to kms"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:kms:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_web_role_to_param_store" {
  role       = aws_iam_role.web_role.name
  policy_arn = aws_iam_policy.allow_access_to_param_store.arn
}

resource "aws_iam_role_policy_attachment" "attach_web_role_to_kms" {
  role       = aws_iam_role.web_role.name
  policy_arn = aws_iam_policy.allow_access_to_kms.arn
}

resource "aws_db_instance" "gfg_postgres" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "11.7"
  instance_class         = "db.t2.micro"
  db_subnet_group_name   = aws_db_subnet_group.gfg_postgres_subnet.name
  name                   = "gfgdb"
  username               = "gfg"
  password               = var.postgres_password
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_db_access.id]
}

resource "aws_db_subnet_group" "gfg_postgres_subnet" {
  name       = "gfg_postgres_subnet"
  subnet_ids = [aws_subnet.net1.id, aws_subnet.net2.id]
}

resource "aws_security_group" "allow_web_access_to_ec2" {
  vpc_id = aws_vpc.gfgnetwork.id

  ingress {
    description = "Allow Web access"
    from_port   = 80
    to_port     = 80
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


resource "aws_security_group" "allow_ssh_access_to_ec2" {
  vpc_id = aws_vpc.gfgnetwork.id

  ingress {
    description = "Allow SSH access"
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

resource "aws_security_group" "allow_db_access" {
  vpc_id = aws_vpc.gfgnetwork.id
  ingress {
    description     = "Allow DB Access"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_web_access_to_ec2.id]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_kms_key" "gfgkey" {}

resource "aws_kms_alias" "gfgkey_alias" {
  name          = "alias/gfg-key-alias"
  target_key_id = aws_kms_key.gfgkey.key_id
}

resource "aws_ssm_parameter" "dbpassword" {
  name   = "gfgdbpassword"
  type   = "SecureString"
  value  = var.postgres_password
  key_id = aws_kms_alias.gfgkey_alias.arn
}
