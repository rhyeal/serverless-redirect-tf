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
  domain_name       = "${var.aliases[0]}"
  subject_alternative_names = "${var.aliases}"
  validation_method = "${var.validation_method}"

  tags = "${module.label.tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = "${aws_acm_certificate.this.arn}"
}

resource "aws_s3_bucket" "this" {
  bucket = "${module.label.id}-s3-bucket"
  acl    = "private"

  tags = "${module.label.tags}"
}

resource "aws_s3_bucket_object" "default" {
  bucket            = "${aws_s3_bucket.this.id}"
  key               = "index.html"
  website_redirect  =   "${var.default_301}"
}

resource "aws_s3_bucket_object" "ordered" {
  count             = "${length(var.ordered_301)}"
  bucket            = "${aws_s3_bucket.this.id}"
  key               = "${replace(element(keys(var.ordered_301), count.index),"/*","")}/index.html"
  website_redirect  =   "${element(values(var.ordered_301), count.index)}"
}

locals {
  s3_origin_id = "${module.label.id}-s3-origin"
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = "${aws_s3_bucket.this.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    # s3_origin_config {
    #   origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

#   logging_config {
#     include_cookies = false
#     bucket          = "mylogs.s3.amazonaws.com"
#     prefix          = "myprefix"
#   }

#   aliases = ["mysite.example.com", "yoursite.example.com"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "POST"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = "${var.forward_query_string}"

      cookies {
        forward = "${var.forward_all_cookies ? "all": "none"}"
      }
    }

    viewer_protocol_policy = "allow-all"
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
    cloudfront_default_certificate = true
  }
}