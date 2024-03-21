resource "aws_iam_role" "k8s_ssm_role" {
  name               = "jingchen-liu-k8s-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
}

data "aws_iam_policy_document" "ssm_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.k8s_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "jingchen-liu-k8s-ssm-profile"
  role = aws_iam_role.k8s_ssm_role.name
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "master1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.medium"
  subnet_id              = element(aws_subnet.private_subnets.*.id, 0)
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.default.id]
  depends_on             = [aws_nat_gateway.k8s_nat]
  tags = {
    Name = "jingchen-liu-k8s-master-1"
  }
}
