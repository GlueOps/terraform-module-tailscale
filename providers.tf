terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.21.1"
    }
  }
}

provider "tailscale" {
  tailnet = var.tailnet_name
}
