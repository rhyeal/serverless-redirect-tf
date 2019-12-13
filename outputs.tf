output "id" {
  value       = "${element(concat(aws_cloudfront_distribution.this.*.id, list("")), 0)}"
  description = "CloudFront distribution ID"
}

output "arn" {
  value       = "${element(concat(aws_cloudfront_distribution.this.*.arn, list("")), 0)}"
  description = "CloudFront distribution ARN"
}

output "domain_name" {
  value       = "${element(concat(aws_cloudfront_distribution.this.*.domain_name, list("")), 0)}"
  description = "CloudFront distribution domain name (for DNS records)"
}
