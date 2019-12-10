# terraform-aws-redirect
Use this Terraform module for a serverless, CloudFront-based redirect

## Usage

```hcl
module "example_redirect" {
  source          = "git::https://github.com/rhyeal/terraform-aws-redirect.git?ref=master"
  namespace       = "example"
  stage           = "development"
  name            = "redirect"

  zone_id         = var.route53_zone_id
  aliases         = var.aliases
  default_301     = "https://google.com"
  ordered_301     = {
    "/example_path/*" = "https://example.com"
  }
}
```

## Examples

Review the [examples](examples/) to see how to use this module.


## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
|namespace|The namespace of the redirect, usually the service name, e.g. my-website|string|``|no|
|stage|The environment, e.g. development|string|``|no|
|name|The name of this microservice|string|``|yes|
|zone_id|The Route53 Zone ID for the creation of DNS records for the SSL certificate|string|``|yes|
|aliases|An array of aliases for the CloudFront distribution. DNS records will be created or updated for these domain names|list(string)|`<list>`|no|
|default_301|The default redirect if no other path matches|URL|`<URL>`|yes|
|ordered_301|A map of paths and destinations for routing before the default redirect|map(string)|`<map>`|yes|
|forward_query_string|Forward the query string to the destination|string|`false`|no|
|forward_all_cookies|Forward cookies to the destination|string|`false`|no|

## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.

#### Thanks to the [Cloud Posse](https://cloudposse.com/) team for the great README template