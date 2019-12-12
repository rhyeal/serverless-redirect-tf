module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

resource "aws_acm_certificate" "this" {
  count             = "${var.enabled ? 1 : 0}"
  domain_name       = "*.${var.domain_name}"
  subject_alternative_names = ["${var.domain_name}"]
  validation_method = "${var.validation_method}"

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  count             = "${var.enabled ? 1 : 0}"
  certificate_arn = "${aws_acm_certificate.this.arn}"
}

resource "aws_s3_bucket" "this" {
  count             = "${var.enabled ? 1 : 0}"
  bucket = "${module.label.id}-s3-bucket"
  acl    = "private"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE", "PUT", "HEAD"]
    allowed_origins = ["*"]
  }

  tags = "${module.label.tags}"
}

resource "aws_s3_bucket_object" "default" {
  count             = "${var.enabled ? 1 : 0}"
  bucket            = "${aws_s3_bucket.this.id}"
  key               = "index.html"
  website_redirect  =   "${var.default_301}"
}

resource "aws_s3_bucket_object" "ordered" {
  count             = "${var.enabled ? length(var.ordered_301) : 0}"
  bucket            = "${aws_s3_bucket.this.id}"
  key               = "${replace(element(keys(var.ordered_301), count.index),"/*","")}/index.html"
  website_redirect  =   "${element(values(var.ordered_301), count.index)}"
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"

      values = ["${var.secret_agent}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.this.arn}"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"

      values = ["${var.secret_agent}"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count             = "${var.enabled ? 1 : 0}"
	bucket = "${aws_s3_bucket.this.id}"
	policy = "${data.aws_iam_policy_document.s3_policy.json}"
}

locals {
  s3_origin_id = "${module.label.id}-s3-origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count             = "${var.enabled ? 1 : 0}"
  comment = "Origin access for ${aws_s3_bucket.this.id}"
}

resource "aws_cloudfront_distribution" "this" {
  count             = "${var.enabled ? 1 : 0}"

  origin {
    domain_name = "${aws_s3_bucket.this.website_endpoint}"
    origin_id   = "${local.s3_origin_id}"

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    custom_header {
      name  = "User-Agent"
      value = "${var.secret_agent}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Redirection CDN"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

  aliases = "${concat(list(var.domain_name), var.aliases)}"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = "${var.forward_query_string}"

      cookies {
        forward = "${var.forward_all_cookies ? "all": "none"}"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

#   # Cache behavior with precedence 0
#   ordered_cache_behavior {
#     path_pattern     = "/content/immutable/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD", "OPTIONS"]
#     target_origin_id = "${local.s3_origin_id}"

#     forwarded_values {
#       query_string = false
#       headers      = ["Origin"]

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 86400
#     max_ttl                = 31536000
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

#   # Cache behavior with precedence 1
#   ordered_cache_behavior {
#     path_pattern     = "/content/*"
#     allowed_methods  = ["GET", "HEAD", "OPTIONS"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = "${local.s3_origin_id}"

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     min_ttl                = 0
#     default_ttl            = 3600
#     max_ttl                = 86400
#     compress               = true
#     viewer_protocol_policy = "redirect-to-https"
#   }

  price_class = "PriceClass_All"

  restrictions {
      geo_restriction {
          restriction_type = "none"
      }
  }

  tags = "${module.label.tags}"

  viewer_certificate {
    acm_certificate_arn = "${ var.acm_arn != "" ? var.acm_arn : aws_acm_certificate.this.arn }"
    ssl_support_method = "sni-only"
  }

  depends_on = ["aws_acm_certificate.this", "aws_acm_certificate_validation.this"]
}
