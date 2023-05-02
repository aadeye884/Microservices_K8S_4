# Worker loadbalancer
resource "aws_lb" "PROD-worker-lb" {
  name               = "PROD-worker-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  security_groups    = [aws_security_group.cluster_sg.id]

  tags = {
    Name = "PROD-worker-lb"
  }
}

#Load Balancer Target Group
resource "aws_lb_target_group" "PROD-worker-tg" {
  name     = "PROD-worker-tg"
  port     = 30002
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

#Load Balancer Listener
resource "aws_lb_listener" "PROD-worker-listener" {
  load_balancer_arn = aws_lb.PROD-worker-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PROD-worker-tg.arn
  }
}

#Load Balancer Target Group Attachment
resource "aws_lb_target_group_attachment" "PROD-worker-attachment" {
  target_group_arn = aws_lb_target_group.PROD-worker-tg.arn
  target_id        = element(split(",", join(",", aws_instance.Worker_nodes.*.id)), count.index)
  port             = 30002
  count            = 3
}

resource "aws_lb_listener" "SSMKPUS-PROD-listener" {
  load_balancer_arn = aws_lb.PROD-worker-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.my_acm_certificate.arn}"
  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.PROD-worker-tg.arn
  }  
}

# STAGE-Worker loadbalancer
resource "aws_lb" "stage-worker-lb" {
  name               = "stage-worker-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  security_groups    = [aws_security_group.cluster_sg.id]
  tags = {
    Name = "stage-workerlb"
  }
}

#Load Balancer Target Group
resource "aws_lb_target_group" "stage-worker-tg" {
  name     = "stage-worker-tg"
  port     = 30001
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

#Load Balancer Listener
resource "aws_lb_listener" "stage-worker-listener" {
  load_balancer_arn = aws_lb.stage-worker-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stage-worker-tg.arn
  }
}

#Load Balancer Target Group Attachment
resource "aws_lb_target_group_attachment" "stage-worker-attachment" {
  target_group_arn = aws_lb_target_group.stage-worker-tg.arn
  target_id        = element(split(",", join(",", aws_instance.Worker_nodes.*.id)), count.index)
  port             = 30001
  count            = 3
}
resource "aws_lb_listener" "SSMKPUS-stage-listener" {
  load_balancer_arn = aws_lb.stage-worker-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.my_acm_certificate.arn}"
  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.stage-worker-tg.arn
  }  
}  


# Prometheus Loadbalancer
resource "aws_lb" "prometheus-lb" {
  name               = "prometheus-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  security_groups    = [aws_security_group.cluster_sg.id]
  tags = {
    Name = "prometheus-lb"
  }
}

# Prometheus Target Group
resource "aws_lb_target_group" "prometheus-tg" {
  name     = "prometheus-tg"
  port     = 31090
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

# Prometheus Listener
resource "aws_lb_listener" "prometheus-listener" {
  load_balancer_arn = aws_lb.prometheus-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus-tg.arn
  }
}

# Prometheus Target Group Attachment
resource "aws_lb_target_group_attachment" "prometheus-attachment" {
  target_group_arn = aws_lb_target_group.prometheus-tg.arn
  target_id        = element(split(",", join(",", aws_instance.Worker_nodes.*.id)), count.index)
  port             = 31090
  count            = 3
}
resource "aws_lb_listener" "SSMKPUS-prometheus-listener" {
  load_balancer_arn = aws_lb.prometheus-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.my_acm_certificate.arn}"
  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.prometheus-tg.arn  
  }  
}

# Grafana Loadbalancer
resource "aws_lb" "grafana-lb" {
  name               = "grafana-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  security_groups    = [aws_security_group.cluster_sg.id]
  tags = {
    Name = "grafana-lb"
  }
}

# Grafana Target Group 
resource "aws_lb_target_group" "grafana-tg" {
  name     = "grafana-tg"
  port     = 31300
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    interval            = 30
    timeout             = 5
  }
}

# Grafana Listener
resource "aws_lb_listener" "grafana-listener" {
  load_balancer_arn = aws_lb.grafana-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana-tg.arn
  }
}

# Grafana Target Group Attachment 
resource "aws_lb_target_group_attachment" "grafana-attachment" {
  target_group_arn = aws_lb_target_group.grafana-tg.arn
  target_id        = element(split(",", join(",", aws_instance.Worker_nodes.*.id)), count.index)
  port             = 31300
  count            = 3
}
resource "aws_lb_listener" "SSMKPUS-grafana-listener" {
  load_balancer_arn = aws_lb.grafana-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.my_acm_certificate.arn}"
  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.grafana-tg.arn 
  }
}    
