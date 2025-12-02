# Redirect Ubuntu apt traffic to your local mirror (UDM/UDM-Pro)

These steps override DNS so LAN clients hit your mirror instead of Ubuntu’s public servers. Assumes UniFi OS 3.x UI and that your mirror is reachable on HTTP (no TLS required for default apt use).

## Steps

1) Ensure clients use the UDM for DNS  
   - Settings → Networks → your LAN → DHCP: DNS server should be the UDM. Otherwise set the UDM manually on clients.

2) Add host overrides on the UDM  
   - Settings → Services → DNS → Hostname.  
   - Add records pointing to your mirror host’s LAN IP:  
     - `archive.ubuntu.com` → `<mirror-IP>`  
     - `security.ubuntu.com` → `<mirror-IP>`  
   - Save/apply.

3) Expose the mirror port  
   - Make sure the mirror host allows inbound from LAN on the port you serve (e.g., 8080 from the compose file).  
   - If you prefer port 80 for apt, either expose 80 on the container/host or add a NAT forward on the mirror host from 80 → 8080.

4) Test from a client  
   - `dig archive.ubuntu.com` should return `<mirror-IP>`.  
   - `curl http://archive.ubuntu.com:8080/ubuntu/dists/` (or `:80` if you moved it) should list directories.  
   - `apt-get update` should now pull from your mirror.

## Notes

- Keeping the archive on HTTP avoids TLS certificate issues. Using HTTPS would require valid certs for `archive.ubuntu.com`/`security.ubuntu.com` and client trust changes.  
- If you have another DNS layer (e.g., Pi-hole), add the same host overrides there or make it forward to the UDM.
