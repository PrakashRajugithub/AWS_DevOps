# The below one is to get MY IP Dynamically.
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}



resource "aws_security_group" "instance-sg" {
  name        = "allow SSH"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.new-vpc.id

  ingress {
    description = "ssh admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
    # The above line is to get IP. "chomp" used for 'if there is any spaces in between the line it will delete the spaces'
  }

  ingress {
    description = "Apache"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  ingress {
    description = "tomcat"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name      = "Instances-sg"
    Terraform = "True"
  }
}

# SSH Key File
resource "aws_key_pair" "ec2" {
  key_name   = "SSH-key"
  public_key = file("C:/Users/PrakashSakiraju/.ssh/id_rsa.pub")
}

# EC2 Instances

# EC2-1
resource "aws_instance" "ec2-instance1" {
  ami           = "ami-0753e0e42b20e96e3"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.instance-sg.id]
  key_name = aws_key_pair.ec2.id
  iam_instance_profile = aws_iam_instance_profile.ec2_codedeploy_instance_profile.name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Hellow People. This is $(hostname -f) First Instance" > /var/www/html/index.html 
              amazon-linux-extras install java-openjdk11
              sudo yum install -y ruby
              sudo yum install -y aws-cli
              cd /home/ec2-user
              wget https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              sudo ./install auto
              sudo service codedeploy-agent start
              sudo service codedeploy-agent enable
              # sudo -i
              # sudo useradd -d /home/tomcat tomcat
              #sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.97/bin/apache-tomcat-9.0.97.tar.gz
              #sudo mkdir -p /opt/tomcat
              #sudo tar -xzf apache-tomcat-9.0.97.tar.gz -C /opt/tomcat --strip-components=1
              # sudo chown -R tomcat:tomcat /opt/tomcat/
              sudo chmod 755 /opt/tomcat/bin/*.sh
              sudo mkdir -p /home/tomcat/deploy/
              EOF
  
  tags = {
    Name = "tomcat-instance1"
    Terraform ="True"
    ENV = "PROD"
  }
}

# EC2-2

resource "aws_instance" "ec2-instance2" {
  ami           = "ami-0753e0e42b20e96e3"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[1].id
  key_name = aws_key_pair.ec2.id
  iam_instance_profile = aws_iam_instance_profile.ec2_codedeploy_instance_profile.name
  vpc_security_group_ids = [aws_security_group.instance-sg.id]
   user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "Hellow People. This is $(hostname -f) Second Instance" > /var/www/html/index.html 
              amazon-linux-extras install java-openjdk11
              sudo yum install -y ruby
              sudo yum install -y aws-cli
              cd /home/ec2-user
              wget https://aws-codedeploy-ap-southeast-1.s3.amazonaws.com/latest/install
              sudo chmod +x ./install
              sudo ./install auto
              sudo service codedeploy-agent start
              sudo service codedeploy-agent enable
              # sudo -i
              # sudo useradd -d /home/tomcat tomcat
              #sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.97/bin/apache-tomcat-9.0.97.tar.gz
              sudo mkdir -p /opt/tomcat
              #sudo tar -xzf apache-tomcat-9.0.97.tar.gz -C /opt/tomcat --strip-components=1
              # sudo chown -R tomcat:tomcat /opt/tomcat/
              sudo chmod 755 /opt/tomcat/bin/*.sh
              sudo mkdir -p /home/tomcat/deploy/
              EOF
  
  tags = {
    Name = "tomcat-instance2"
    Terraform ="True"
    ENV = "PROD"
  }

 }

# # Starting & Stopping EC2's
# # EC2-1 

resource "aws_ec2_instance_state" "ec2-1" {
  instance_id = aws_instance.ec2-instance1.id
  state       = "running"
}

# # EC2-2

resource "aws_ec2_instance_state" "ec2-2" {
  instance_id = aws_instance.ec2-instance2.id
  state       = "running"
}