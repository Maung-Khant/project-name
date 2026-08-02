# DHCP & DNS Server — Linux SysAdmin Project Proposal

**Submitted by:** @sample
**Date of Submission:** 2026-08-02
**Target Environment:** Ubuntu 24.04 LTS
**Repository / Code Base:** https://github.com/ammdevl/project-name

## Gist

A local network DHCP and DNS server using ISC DHCP and BIND9, providing automatic IP assignment and domain name resolution for a school lab environment.

## Story

In a school computer lab, the sysadmin manually assigns static IPs to 30+ machines every semester. When a new device joins the network, it can't connect until the admin updates the config. Students waste class time waiting for network access. An automated DHCP server eliminates manual IP management, and a local DNS server lets users reach lab machines by hostname instead of remembering IPs.

## Why

- Eliminates manual IP assignment, reducing setup time from hours to minutes when new devices join the network.
- Provides local DNS resolution so lab machines are reachable by name (e.g., `lab-pc01.local`), improving usability for students and staff.
- Creates a foundation the team can extend with PXE boot or network segmentation in future phases.

## Why Not

- No public-facing DNS (no domain registration or external DNS hosting).
- No PXE boot or diskless workstation setup — that is a separate future project.
- No HA/failover configuration — this is a single-server deployment for a lab, not production.
- No IPv6 — the lab network uses IPv4 only.

## Tech Spec

- **OS / Distro:** Ubuntu 24.04 LTS
- **Core Services & Packages:**
  - `isc-dhcp-server` — DHCP service for dynamic IP allocation
  - `bind9` — DNS server for local name resolution
  - `bind9utils` — DNS utilities (`dig`, `nslookup`)
  - `ufw` — firewall configuration
- **Automation / Config:**
  - Bash scripts for initial server setup and configuration deployment
  - Config files managed as plain text in the repository (no Ansible for this phase)
- **Architecture / Flow:**
  ```
  Client Request → DHCP Server (ISC) → Assigns IP from pool
  DNS Query → BIND9 → Resolves lab-pc01.local → 192.168.1.101
  ```
  - DHCP scope: `192.168.1.100 — 192.168.1.200`
  - DNS zone: `lab.local`
  - Gateway: `192.168.1.1`

## Security & Backup Plan

- Restrict DHCP to the lab subnet only — no relay across network segments.
- BIND9 configured as authoritative for `lab.local` only — no open recursion to prevent abuse.
- UFW allows only DHCP (UDP 67/68) and DNS (UDP/TCP 53) from the lab subnet.
- Config files backed up to the project repository after each change.

## Definition of Done

- [ ] ISC DHCP server assigns IPs to all lab machines from the defined pool.
- [ ] BIND9 resolves hostnames in the `lab.local` zone correctly.
- [ ] `dig lab-pc01.lab.local` returns the correct IP address.
- [ ] Firewall blocks DNS and DHCP traffic from outside the lab subnet.
- [ ] DHCP and DNS services survive a server reboot (`systemctl enable`).
- [ ] Configuration backup script runs without errors.

## Key References & Documentation

- [Ubuntu Server Guide](https://ubuntu.com/server/docs)
- [ISC DHCP Documentation](https://kb.isc.org/docs/isc-dhcp-44-manual-pages-dhcpd)
- [BIND9 Administrator Reference Manual](https://ftp.isc.org/isc/bind9/cur/doc/arm/man.named.html)
- [Ubuntu DHCP Server Tutorial](https://help.ubuntu.com/community/ISC_DHCP)
