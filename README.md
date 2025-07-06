# terraform-module-tailscale
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | 0.21.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.21.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [tailscale_acl.acl_config](https://registry.terraform.io/providers/tailscale/tailscale/0.21.1/docs/resources/acl) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cde_entities"></a> [cde\_entities](#input\_cde\_entities) | List of entities that need CDE access | `list(string)` | <pre>[<br/>  "apple",<br/>  "google",<br/>  "netflix"<br/>]</pre> | no |
| <a name="input_groups"></a> [groups](#input\_groups) | Map of group names to list of user emails | `map(list(string))` | <pre>{<br/>  "group:everyone": [<br/>    "tim.cook@example.com",<br/>    "steve.jobs@example.com",<br/>    "steve.wozniak@example.com"<br/>  ],<br/>  "group:nonprod-cde-admins": [<br/>    "steve.wozniak@example.com",<br/>    "tim.cook@example.com"<br/>  ],<br/>  "group:prod-cde-admins": [<br/>    "steve.wozniak@example.com",<br/>    "tim.cook@example.com"<br/>  ],<br/>  "group:sysadmins": [<br/>    "steve.jobs@example.com"<br/>  ]<br/>}</pre> | no |
| <a name="input_shared_resources"></a> [shared\_resources](#input\_shared\_resources) | Shared resources configuration for each entity | <pre>map(map(object({<br/>    tag         = string<br/>    description = string<br/>    environment = string<br/>    access = object({<br/>      ports = list(string)<br/>    })<br/>  })))</pre> | <pre>{<br/>  "apple": {<br/>    "metrics_prod": {<br/>      "access": {<br/>        "ports": [<br/>          "tcp:9090"<br/>        ]<br/>      },<br/>      "description": "Production metrics server for apple VMs",<br/>      "environment": "prod",<br/>      "tag": "tag:shared-metrics-prod-apple"<br/>    },<br/>    "registry_cache": {<br/>      "access": {<br/>        "ports": [<br/>          "tcp:1111",<br/>          "tcp:1112"<br/>        ]<br/>      },<br/>      "description": "Shared registry cache for apple VMs",<br/>      "environment": "global",<br/>      "tag": "tag:shared-registry-cache-apple"<br/>    },<br/>    "test_db": {<br/>      "access": {<br/>        "ports": [<br/>          "tcp:5432"<br/>        ]<br/>      },<br/>      "description": "Shared test database for nonprod apple VMs",<br/>      "environment": "nonprod",<br/>      "tag": "tag:shared-testdb-nonprod-apple"<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_users"></a> [users](#input\_users) | n/a | `list(string)` | <pre>[<br/>  "tim.cook@example.com",<br/>  "steve.jobs@example.com",<br/>  "steve.wozniak@example.com"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->