locals {
  # Generate tag maps for each entity
  cde_vm_tags = {
    for entity in var.cde_entities : entity => {
      nonprod = "tag:app-nonprod-cde-vm-${entity}"
      prod    = "tag:app-prod-cde-vm-${entity}"
    }
  }

  cde_bastion_tags = {
    for entity in var.cde_entities : entity => {
      nonprod = "tag:app-nonprod-cde-bastion-${entity}"
      prod    = "tag:app-prod-cde-bastion-${entity}"
    }
  }

  cde_exit_node_tags = {
    for entity in var.cde_entities : entity => {
      nonprod = "tag:app-nonprod-cde-exitnode-${entity}"
      prod    = "tag:app-prod-cde-exitnode-${entity}"
    }
  }

  # Flatten VM tags for easy access
  all_nonprod_vm_tags = [for entity in var.cde_entities : local.cde_vm_tags[entity].nonprod]
  all_prod_vm_tags    = [for entity in var.cde_entities : local.cde_vm_tags[entity].prod]

  # Helper to get all enabled exit node tags (for sysadmin access)
  all_exit_node_tags = flatten([
    for entity, config in var.exit_nodes_enabled : concat(
      config.nonprod ? [local.cde_exit_node_tags[entity].nonprod] : [],
      config.prod ? [local.cde_exit_node_tags[entity].prod] : []
    )
  ])

  # Helper function to get VM tags based on environment and entity
  get_vm_tags_for_env = {
    global = { for entity in var.cde_entities : entity => [
      local.cde_vm_tags[entity].nonprod,
      local.cde_vm_tags[entity].prod
    ] }
    prod    = { for entity in var.cde_entities : entity => [local.cde_vm_tags[entity].prod] }
    nonprod = { for entity in var.cde_entities : entity => [local.cde_vm_tags[entity].nonprod] }
  }

  # Generate shared resource access rules
  shared_resource_rules = flatten([
    for entity, resources in var.shared_resources : [
      for resource_name, resource in resources : {
        resource_tag = resource.tag
        # Get the appropriate VM tags based on the resource's environment setting
        src_tags = local.get_vm_tags_for_env[resource.environment][entity]
        ports    = resource.access.ports
      }
    ]
  ])

  # Generate tag owners map
  cde_tag_owners = merge(
    # Basic CDE tag owners
    merge(flatten([
      for entity in var.cde_entities : [
        {
          "${local.cde_vm_tags[entity].nonprod}"      = ["group:nonprod-cde-admins"]
          "${local.cde_vm_tags[entity].prod}"         = ["group:prod-cde-admins"]
          "${local.cde_bastion_tags[entity].nonprod}" = ["group:nonprod-cde-admins"]
          "${local.cde_bastion_tags[entity].prod}"    = ["group:prod-cde-admins"]
        }
      ]
    ])...),
    # Exit node tag owners - only for entities with exit nodes enabled
    merge(flatten([
      for entity, config in var.exit_nodes_enabled : [
        merge(
          config.nonprod ? { "${local.cde_exit_node_tags[entity].nonprod}" = ["group:nonprod-cde-admins"] } : {},
          config.prod ? { "${local.cde_exit_node_tags[entity].prod}" = ["group:prod-cde-admins"] } : {}
        )
      ]
    ])...),
    # Shared resource tag owners - assign owners based on environment
    merge([
      for entity, resources in var.shared_resources : {
        for resource_name, resource in resources : resource.tag => (
          resource.environment == "global" ? ["group:prod-cde-admins", "group:nonprod-cde-admins"] :
          resource.environment == "prod" ? ["group:prod-cde-admins"] :
          ["group:nonprod-cde-admins"]
        )
      }
    ]...)
  )
}
