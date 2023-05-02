#Importing route 53 hosted zone from AWS console
#Get details about Route 53 hosted zone
data "aws_route53_zone" "route53_zone" {
  name         = "volakinwand.com"
  private_zone = false

}

resource "aws_route53_record" "stage_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.stage_domain_hosted_zone
  type    = "A"

  alias {
    name                   = aws_lb.stage-worker-lb.dns_name
    zone_id                = aws_lb.stage-worker-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "prod_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.prod_domain_hosted_zone
  type    = "A"

  alias {
    name                   = aws_lb.PROD-worker-lb.dns_name
    zone_id                = aws_lb.PROD-worker-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "prometheus_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.prometheus_domain_hosted_zone
  type    = "A"

  alias {
    name                   = aws_lb.prometheus-lb.dns_name
    zone_id                = aws_lb.prometheus-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_route53_record" "grafana_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = var.grafana_domain_hosted_zone
  type    = "A"

  alias {
    name                   = aws_lb.grafana-lb.dns_name
    zone_id                = aws_lb.grafana-lb.zone_id
    evaluate_target_health = true
  }

}

resource "aws_acm_certificate" "my_acm_certificate" {
  domain_name               = "volakinwand.com"
  subject_alternative_names = ["*.volakinwand.com"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

# create a record set in route 53 for domain validatation
resource "aws_route53_record" "route53_record" {
  for_each = {
    for dvo in aws_acm_certificate.my_acm_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}
# validate acm certificates
resource "aws_acm_certificate_validation" "acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.my_acm_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.route53_record : record.fqdn]
}
