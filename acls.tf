resource "tailscale_acl" "acl_config" {
  overwrite_existing_content = true
  acl = jsonencode({

    # Tag Notes:
    ## cde = cloud-development-environments
    ## vm = virtual machine

    tagOwners = merge(
      {
        "tag:sharedssh" = ["autogroup:admin"],
        "tag:ci"        = ["autogroup:admin"],
        "tag:exitnode"  = ["autogroup:admin"],
        "tag:app-nonprod-provisioner-nodes" : ["group:nonprod-cde-admins"],
        "tag:app-prod-provisioner-nodes" : ["group:prod-cde-admins"],
        "tag:captain-clusters" : ["group:captain-cluster-admins"]
      },
      local.cde_tag_owners
    )

    groups = var.groups
    grants = concat(
      [
        {
          src = ["group:sysadmins"],
          dst = ["autogroup:tagged"],
          "ip" : ["*"]
        },
        {
          src = ["group:everyone"],
          dst = ["autogroup:internet"],
          "ip" : ["*"]
        },
        {
          src = ["group:prod-cde-admins"],
          dst = concat(
            ["tag:app-prod-provisioner-nodes"],
            local.all_prod_vm_tags
          ),
          "ip" : ["tcp:22"]
        },
        {
          src = ["group:nonprod-cde-admins"],
          dst = concat(
            ["tag:app-nonprod-provisioner-nodes"],
            local.all_nonprod_vm_tags
          ),
          "ip" : ["tcp:22"]
        },
        {
          src = ["group:captain-cluster-admins"],
          dst = ["tag:captain-clusters"],
          "ip" : ["tcp:22"]
        }
      ],
      # Generate bastion to VM access rules for each entity
      flatten([
        for entity in var.cde_entities : [
          {
            src = [local.cde_bastion_tags[entity].nonprod],
            dst = [local.cde_vm_tags[entity].nonprod],
            "ip" : ["tcp:22"]
          },
          {
            src = [local.cde_bastion_tags[entity].prod],
            dst = [local.cde_vm_tags[entity].prod],
            "ip" : ["tcp:22"]
          }
        ]
      ]),
      # Add shared resource access rules
      [
        for rule in local.shared_resource_rules : {
          src = rule.src_tags
          dst = [rule.resource_tag]
          ip  = rule.ports
        }
      ]
    )

    ssh = concat(
      [
        {
          action = "check",
          src    = ["autogroup:member"],
          dst    = ["autogroup:self"],
          users  = ["autogroup:nonroot", "root", "group:sysadmins"],
        },
        {
          "action" : "check",
          "src" : ["group:prod-cde-admins", "group:sysadmins"],
          "dst" : concat(
            ["tag:app-prod-provisioner-nodes"],
            local.all_prod_vm_tags
          ),
          "users" : ["autogroup:nonroot", "root"],
        },
        {
          "action" : "check",
          "src" : ["group:prod-cde-admins", "group:sysadmins"],
          "dst" : concat(
            ["tag:app-nonprod-provisioner-nodes"],
            local.all_nonprod_vm_tags
          ),
          "users" : ["autogroup:nonroot", "root"],
        },
        {
          "action" : "check",
          "src" : ["group:captain-cluster-admins", "group:sysadmins"],
          "dst" : ["tag:captain-clusters"],
          "users" : ["autogroup:nonroot", "root"],
        }
      ],
      # Generate SSH access rules for each entity's bastion to VM
      flatten([
        for entity in var.cde_entities : [
          {
            "action" : "accept",
            "src" : [local.cde_bastion_tags[entity].nonprod],
            "dst" : [local.cde_vm_tags[entity].nonprod],
            "users" : ["autogroup:nonroot", "root"],
          },
          {
            "action" : "accept",
            "src" : [local.cde_bastion_tags[entity].prod],
            "dst" : [local.cde_vm_tags[entity].prod],
            "users" : ["autogroup:nonroot", "root"],
          }
        ]
      ]),
      [
        {
          "action" : "check",
          "src" : ["group:sysadmins"],
          "dst" : ["autogroup:tagged"],
          "users" : ["autogroup:nonroot", "root"],
        }
      ]
    )
  })
}
