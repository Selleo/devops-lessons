module "load_balancer" {
  source  = "Selleo/backend/aws//modules/load-balancer"
  version = "0.8.1"

  name       = "workshop-03"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = module.load_balancer.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = module.load_balancer.id
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = module.acm.arn
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = module.ecs_service.lb_target_group_id
    type             = "forward"
  }
}
