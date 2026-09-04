terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.29.2"
    }
  }
}

provider "tailscale" {
  tailnet = var.tailnet_name
}
