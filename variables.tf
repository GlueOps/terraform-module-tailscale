variable "tailnet_name" {
  description = "Name of tailnet"
  type        = string
}

variable "cde_entities" {
  description = "List of entities that need CDE access"
  type        = list(string)
  default = [
    "apple",
    "google",
    "netflix"
  ]
}

variable "shared_resources" {
  description = "Shared resources configuration for each entity"
  type = map(map(object({
    tag         = string
    description = string
    environment = string
    access = object({
      ports = list(string)
    })
  })))
  default = {
    apple = {
      # Global resource example (accessible by both prod and nonprod)
      registry_cache = {
        tag         = "tag:shared-registry-cache-apple"
        description = "Shared registry cache for apple VMs"
        environment = "global" # Can be "global", "prod", or "nonprod"
        access = {
          ports = ["tcp:1111", "tcp:1112"]
        }
      },
      # Prod-only resource example
      metrics_prod = {
        tag         = "tag:shared-metrics-prod-apple"
        description = "Production metrics server for apple VMs"
        environment = "prod"
        access = {
          ports = ["tcp:9090"]
        }
      },
      # Nonprod-only resource example
      test_db = {
        tag         = "tag:shared-testdb-nonprod-apple"
        description = "Shared test database for nonprod apple VMs"
        environment = "nonprod"
        access = {
          ports = ["tcp:5432"]
        }
      }
    }
    # Add shared resources for other entities as needed
    # google = {
    #   resource_name = { ... }
    # }
  }
}

variable "users" {
  type = list(string)
  default = [
    "tim.cook@example.com",
    "steve.jobs@example.com",
    "steve.wozniak@example.com"
  ]
}

variable "groups" {
  description = "Map of group names to list of user emails"
  type        = map(list(string))
  default = {
    "group:sysadmins" = [
      "steve.jobs@example.com",
    ],
    "group:captain-cluster-admins" = [
      "steve.jobs@example.com",
    ],
    "group:prod-cde-admins" = [
      "steve.wozniak@example.com",
      "tim.cook@example.com"
    ],
    "group:nonprod-cde-admins" = [
      "steve.wozniak@example.com",
      "tim.cook@example.com"
    ],
    "group:everyone" = [
      "tim.cook@example.com",
      "steve.jobs@example.com",
      "steve.wozniak@example.com"
    ]
  }
}


