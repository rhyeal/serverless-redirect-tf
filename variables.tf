variable "namespace" {
    type        = "string"
    default     = ""
    description = "The namespace of the redirect, usually the service name, e.g. my-website"
}

variable "name" {
    type        = "string"
    default     = ""
    description = "The name of this microservice"
}

variable "stage" {
    type        = "string"
    default     = ""
    description = "The environment, e.g. development"
}

variable "zone_id" {
    type        = "string"
    default     = ""
    description = "The Route53 Zone ID for the creation of DNS records for the SSL certificate"
}

variable "aliases" {
    type        = "list"
    default     = []
    description = "An array of aliases for the CloudFront distribution. DNS records will be created or updated for these domain names"
}

variable "default_301" {
    type        = "string"
    default     = ""
    description = "The default redirect if no other path matches"
}

variable "ordered_301" {
    type        = "map"
    default     = {}
    description = "A map of paths and destinations for routing before the default redirect"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter between `name`, `namespace`, `stage` and `attributes`"
}

variable "attributes" {
  type        = "list"
  description = "Additional attributes (_e.g._ \"1\")"
  default     = []
}

variable "tags" {
  type        = "map"
  description = "Additional tags (_e.g._ map(\"BusinessUnit\",\"ABC\")"
  default     = {}
}

variable "forward_query_string" {
  type        = "string"
  description = "Forward the query string to the destination"
  default     = "false"
}

variable "forward_all_cookies" {
  type        = "string"
  description = "Forward cookies to the destination"
  default     = "false"
}

variable "validation_method" {
    type      = "string"
    default   = "DNS"
    description = "How to validate the ACM cert"
}

variable "email" {
    type      = "string"
    default   = ""
    description = "The email for validation"
}

variable "acm_arn" {
    type = "string"
    default = ""
    description = "An existing ACM ARN to use for the CloudFront distribution"
}