resource "aws_launch_configuration" "terraform-ASG-Webserver" {
    image_id = "${var.image_id}"
    instance_type = "${var.instance_type}"
    security_groups = [aws_security_group.SG1.id]
        
    lifecycle {
      create_before_destroy = true 
    }

    

    user_data = <<-EOF
                #!/bin/bash
                sudo dnf update -y
                sudo dnf install httpd -y
                sudo systemctl enable httpd
                sudo systemctl start httpd
                #sudo echo "Hello, World" > /var/www/html/index.html
                #sudo sed /var/www/html > /var/www/html/index.html           
                EOF     
}

 
resource "aws_security_group" "SG1" {
  name        = "Terraform-ASG-SG"
  
  ingress {
    from_port        = var.server_port
    to_port          = var.server_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }  

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
 }


resource "aws_autoscaling_group" "terraform-ASG" {
  launch_configuration = aws_launch_configuration.terraform-ASG-Webserver.name

  min_size = 2
  desired_capacity = 2
  max_size = 4
  availability_zones = ["us-east-2a", "us-east-2b"]  

  tag {
    key = "Name"
    value = "terraform-ASG-Webserver"
    propagate_at_launch = true
  }
}






