output "id" {
  value       = "${aws_cloudfront_distribution.this.0.id}"
  description = "CloudFront distribution ID"
}

output "arn" {
  value       = "${aws_cloudfront_distribution.this.0.arn}"
  description = "CloudFront distribution ARN"
}

output "domain_name" {
  value       = "${aws_cloudfront_distribution.this.0.domain_name}"
  description = "CloudFront distribution domain name (for DNS records)"
}
