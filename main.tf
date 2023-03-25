data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm*"]
  }
}

data "template_file" "userdata" {
  template = file("${abspath(path.module)}/userdata.sh") #Dosya içini okumak için file fonk. belirtilen dosyayı absolute path abspath fonk kullanıyoruz bunlar terraforma gömülü fonks.  
  vars = {
    server-name = var.server-name
  }
}

resource "aws_instance" "tfmyec2" {
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = var.instance_type
  count = var.num_of_instance
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  user_data = data.template_file.userdata.rendered # işlenmiş dosyayı almak için rendered kullanılır
  tags = {
    Name = var.tag
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = "${var.tag}-terraform-sec-grp"
  tags = {
    Name = var.tag
  }
    # tekrar eden durumlar varsa dynamic ile bu tekrar durumunu düzenleyebiliriz
  dynamic "ingress" {
    for_each = var.docker-instance-ports # oluşturduğumuz listedeki değerleri dynamic ile çekiyoruz
    iterator = port #(değişen kısımları iterator ile alıyoruz) for each te belirlernen var daki değeri aktarmamızı sağlıyor port değerlerine
    content {
      from_port = port.value
      to_port = port.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port =0
    protocol = "-1" # all
    to_port =0
    cidr_blocks = ["0.0.0.0/0"]
  }
}