resource "tailscale_dns_nameservers" "nameservers" {
  nameservers = [
    "1.1.1.1", #cloudflare
    "8.8.8.8", #google
    "9.9.9.9", #quad9
    "1.0.0.1", #cloudflare
    "8.8.4.4", #google
    "149.112.112.112", #cloudflare
    "2606:4700:4700::1111", #cloudflare
    "2001:4860:4860::8888", #google
    "2620:fe::fe", #quad9
    "2606:4700:4700::1001", #cloudflare
    "2001:4860:4860::8844", #google
    "2620:fe::9" #quad9
  ]
}
