terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.25.0"
    }
  }
}

provider "tailscale" {
  tailnet = var.tailnet_name
}
