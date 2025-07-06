# terraform-module-tailscale
<!-- BEGIN_TF_DOCS -->
# terraform-module-tailscale

A Terraform module for managing Tailscale ACL (Access Control List) configuration for Cloud Development Environment (CDE) infrastructure. This module provides a structured approach to managing network access policies for multiple entities with separate production and non-production environments.

## Features

- **Multi-entity Support**: Manages access policies for multiple entities (e.g., apple, google, netflix)
- **Environment Separation**: Distinct prod and nonprod environments with appropriate access controls
- **Shared Resources**: Configurable shared resources with environment-specific access
- **Bastion Host Access**: Secure SSH access through bastion hosts for each entity
- **Group-based Permissions**: Role-based access control with admin groups
- **Automated Tag Management**: Automatic generation of Tailscale tags for VMs and bastions

## Architecture

The module creates a comprehensive ACL configuration that includes:

- **VM Tags**: Separate tags for prod/nonprod VMs per entity (`tag:app-{env}-cde-vm-{entity}`)
- **Bastion Tags**: Separate tags for prod/nonprod bastions per entity (`tag:app-{env}-cde-bastion-{entity}`)
- **Shared Resource Tags**: Configurable tags for shared infrastructure
- **Access Rules**: Network access policies between components
- **SSH Rules**: Secure shell access controls

## Usage

```hcl
module "tailscale_acl" {
  source = "path/to/terraform-module-tailscale"

  tailnet_name = "your-tailnet-name"
  cde_entities = [
    "apple",
    "google",
    "netflix"
  ]

  groups = {
    "group:sysadmins" = [
      "admin@example.com"
    ]
    "group:prod-cde-admins" = [
      "prod-admin@example.com"
    ]
    "group:nonprod-cde-admins" = [
      "nonprod-admin@example.com"
    ]
    "group:everyone" = [
      "user1@example.com",
      "user2@example.com"
    ]
  }

  shared_resources = {
    apple = {
      registry_cache = {
        tag         = "tag:shared-registry-cache-apple"
        description = "Shared registry cache for apple VMs"
        environment = "global"
        access = {
          ports = ["tcp:1111", "tcp:1112"]
        }
      }
    }
  }
}
```

## Access Patterns

The module implements several access patterns:

1. **Admin Access**: Sysadmins have full access to all tagged resources
2. **Environment-specific Access**: Prod/nonprod admins can only access their respective environments
3. **Bastion-to-VM Access**: Bastions can SSH to VMs within the same entity and environment
4. **Shared Resource Access**: VMs can access shared resources based on environment compatibility
5. **Internet Access**: All users can access the internet through Tailscale

## Shared Resources

Shared resources can be configured with three environment types:

- **global**: Accessible by both prod and nonprod VMs
- **prod**: Only accessible by production VMs
- **nonprod**: Only accessible by non-production VMs

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
| <a name="input_tailnet_name"></a> [tailnet\_name](#input\_tailnet\_name) | Name of tailnet | `string` | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | n/a | `list(string)` | <pre>[<br/>  "tim.cook@example.com",<br/>  "steve.jobs@example.com",<br/>  "steve.wozniak@example.com"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->