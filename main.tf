resource "aws_instance" "wordpress_server" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

variable "ssh_public_key" {
  type = string
}

resource "aws_key_pair" "deployer" {
  key_name   = "rob-web-server-key"
  public_key = var.ssh_public_key
}

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd php php-mysqlnd mariadb105-server wget

              systemctl start mariadb
              systemctl enable mariadb

              mysql -e "CREATE DATABASE wordpress;"
              mysql -e "CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'ChangeMe123!';"
              mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';"
              mysql -e "FLUSH PRIVILEGES;"

              cd /tmp
              wget https://wordpress.org/latest.tar.gz
              tar -xzf latest.tar.gz
              cp -r wordpress/* /var/www/html/

              cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
              sed -i "s/database_name_here/wordpress/" /var/www/html/wp-config.php
              sed -i "s/username_here/wpuser/" /var/www/html/wp-config.php
              sed -i "s/password_here/ChangeMe123!/" /var/www/html/wp-config.php

              chown -R apache:apache /var/www/html
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "rob-wordpress-server"
  }
}

output "wordpress_url" {
  value = "http://${aws_instance.wordpress_server.public_ip}"
}