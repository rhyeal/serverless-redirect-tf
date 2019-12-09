output "id" {
  value       = "${aws_cloudfront_distribution.this.id}"
  description = "CloudFront distribution ID"
}

output "arn" {
  value       = "${aws_cloudfront_distribution.this.arn}"
  description = "CloudFront distribution ARN"
}

output "domain_name" {
  value       = "${aws_cloudfront_distribution.this.domain_name}"
  description = "CloudFront distribution domain name (for DNS records)"
}