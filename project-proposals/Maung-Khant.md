# Project Proposal: Implementation of DHCP & DNS Combo Server on Ubuntu Linux

**Submitted by:** Maung-Khant (Team of 9 Members)  
**Course:** Linux Fundamentals and  System Administration(CST-311) / Computer Networks(CST-401)  
**Date of Submission:** 2026-08-18  
**Target Environment:** Ubuntu 24.04 LTS (host, Virtual Lab Environment)

---

### Gist
This project involves the practical implementation of a combined **DHCP (isc-dhcp-server)** and **DNS (BIND9)** server on the Ubuntu Linux operating system. The goal is to configure a centralized server that automatically assigns IP addresses to client machines and resolves local hostnames within a controlled laboratory network.

---

### Story
We are a group of 9 undergraduate students from the University of Computer Studies, Yangon. Currently, we are enrolled in the "Linux Fundamentals and System Administration" and Computer Network course, which covers fundamental network services. While we have studied the theoretical concepts of DHCP (Dynamic Host Configuration Protocol) and DNS (Domain Name System) in our networking classes, we have had limited hands-on experience with their actual implementation on a Linux server.

This project serves as our practical examination (practical exam) for the semester. Our primary challenge is not a failing network, but rather bridging the gap between textbook knowledge and real-world system administration skills. By building this server from scratch, we aim to transform our theoretical understanding into practical expertise. We will navigate the Linux filesystem, edit configuration files, manage system services, and troubleshoot issues in a terminal environment.

Successfully completing this project will demonstrate our ability to:
1.  Install and configure core network services on a headless Linux server.
2.  Apply Linux security principles, including user/group management and file permissions.
3.  Collaborate effectively as a team using Git and GitHub for version control.

---

### Why
We selected this specific project for the following reasons:

1.  **Curriculum Alignment (သင်ရိုးညွှန်းတမ်းနဲ့ ကိုက်ညီခြင်း)**:
    This project directly reinforces the key topics covered in our course: Networking fundamentals, Linux daemons (services), Shell scripting, and Security policies. It is the perfect capstone for our semester's learning.
2.  **Hands-on Skill Development (လက်တွေ့ကျွမ်းကျင်မှု ရရှိခြင်း)**:
    Instead of just reading about `dhcpd.conf` or `named.conf`, we will write them ourselves. This will solidify our understanding of how the internet and local networks actually function at the protocol level.
3.  **Team Collaboration & Workflow (အဖွဲ့လိုက်ပူးပေါင်းလုပ်ဆောင်ခြင်း)**:
    With 9 members, this project forces us to practice professional software development workflows using Git branching, pull requests, and code reviews. We will learn how to divide a large system into manageable modules (DHCP Team, DNS Team, Security Team).
4.  **Career Readiness (အလုပ်အကိုင်အတွက် အသင့်ဖြစ်ခြင်း)**:
    DNS and DHCP are foundational services used in every enterprise IT environment. Adding this project to our portfolios will make us stand out to future employers.

---

### Why Not
It is important to define the scope of this project to set realistic expectations for our instructors and ourselves.

1.  **Not a Production Deployment**: This server is strictly for educational and lab testing purposes. It will run on a virtual machine (VirtualBox/VMware), not on a physical server handling real user traffic.
2.  **No High Availability (HA) / Clustering**: We will configure only a single server. We will not implement failover, load balancing, or redundant DHCP/DNS servers (this is beyond the scope of our current syllabus).
3.  **No Advanced Security Hardening**: While we will implement basic security (UFW firewall, service isolation), we will not configure SSL/TLS for DNS (DNSSEC) or complex intrusion detection systems.
4.  **IPv4 Only**: Our lab network uses IPv4. We will not configure IPv6 addressing or zones.
5.  **No Web Interface**: All configurations will be performed via the command line (SSH). We will not install any GUI management tools like Webmin.
6.  **Not a PXE/Network Boot Server**: The scope is strictly limited to IP assignment and name resolution.

---

### Tech Spec

- **Operating System:** Ubuntu 24.04 LTS (Server Edition)
- **Virtualization Platform:** Oracle VirtualBox (or VMware Workstation)
- **Core Packages:**
  - `isc-dhcp-server` - Provides DHCP service.
  - `bind9` & `bind9utils` - Provides DNS service.
  - `ufw` - Uncomplicated Firewall for basic security.
  - `openssh-server` - For remote administration.
- **Network Architecture (Lab Subnet):**
  - **Network Range:** `192.168.1.0/24`
  - **DHCP Pool:** `192.168.1.100` to `192.168.1.200`
  - **Server Static IP:** `192.168.1.10` (Manual assigned to the server itself)
  - **Default Gateway:** `192.168.1.1`
  - **Domain Name:** `lab.local`
- **Automation:**
  - Simple Bash scripts to verify service status and backup configuration files.
  - Version control via Git.

---

### User & Group Management (Mandatory Feature)

We will implement strict user/group isolation for security:

1.  **System Users for Services**:
    - The DHCP service (`isc-dhcp-server`) will run under the system user `dhcpd`.
    - The DNS service (`bind9`) will run under the system user `bind`.
    - These users will have restricted shells (`/usr/sbin/nologin`) to prevent interactive login.

2.  **Administrative Group (netadmin)**:
    - We will create a new group named `netadmin`.
    - All 9 team members will be added to this group.
    - Using `visudo` (sudoers file), we will grant the `netadmin` group permission to execute only the necessary `systemctl` commands (e.g., `sudo systemctl restart bind9`, `sudo systemctl restart isc-dhcp-server`) without needing a password. This aligns with the principle of least privilege.

---

### File & Directory Permissions (Mandatory Feature)

We will strictly manage file ownership and permissions to protect system integrity:

| Directory / File | Owner:Group | Permissions (chmod) | Explanation |
| :--- | :--- | :--- | :--- |
| `/etc/bind/` (Zone files) | `root:bind` | `755` (Dir) / `644` (Files) | The `bind` user (DNS service) must have read access to these files to serve DNS queries, but only `root` can modify them. |
| `/var/lib/dhcp/dhcpd.leases` | `root:dhcpd` | `664` | The `dhcpd` user must have write access to this file to log which IP addresses have been assigned. |
| `/etc/dhcp/dhcpd.conf` | `root:root` | `644` | The main DHCP configuration file. Readable by `dhcpd`, but only editable by `root`. |
| `/opt/backup/` | `root:netadmin` | `750` | Backup directory for config files. Only the `netadmin` group and `root` can access it. |

---

### Security & Backup Plan

1.  **Firewall (UFW) Configuration**:
    - Allow SSH (Port 22) only from the host machine or local subnet.
    - Allow DHCP (UDP 67/68) and DNS (UDP/TCP 53) only from the `192.168.1.0/24` subnet.
    - Deny all other incoming traffic by default.

2.  **DNS Recursion Restriction**:
    - BIND9 will be configured to allow recursive queries only for the `192.168.1.0/24` subnet to prevent use as an open resolver (preventing DDoS attacks).

3.  **Backup Strategy**:
    - A cron job will be scheduled to run every night at 2:00 AM.
    - The script will compress `/etc/bind/` and `/etc/dhcp/` into a `.tar.gz` file.
    - The backup will be stored in `/opt/backup/` and committed to a separate branch in our Git repository weekly for safekeeping.

---

### Definition of Done (DoD) - Grading Checklist

Our project will be considered "Complete" and ready for submission when the following criteria are met. (Instructors will test this):

- [ ] **DHCP Verification**: When a test client machine (on the same subnet) runs `ip a` or `ipconfig`, it successfully receives an IP address from the `192.168.1.100-200` range, along with the correct Gateway (`192.168.1.1`) and DNS (`192.168.1.10`).
- [ ] **DNS Forward Lookup**: From the client machine, `nslookup server.lab.local` or `dig server.lab.local` returns the server's IP (`192.168.1.10`).
- [ ] **DNS Reverse Lookup**: From the client machine, `nslookup 192.168.1.10` returns the hostname `server.lab.local`.
- [ ] **External Forwarding**: The client machine can successfully ping `google.com` (validates DNS forwarding to 8.8.8.8 or similar).
- [ ] **Service Persistence**: The system reboots (`sudo reboot`), and both `systemctl status bind9` and `systemctl status isc-dhcp-server` show `active (running)` without manual intervention.
- [ ] **Permission Check**:
    - User not in `netadmin` group fails to restart services (`Permission denied`).
    - User in `netadmin` group successfully restarts services without a password prompt.
- [ ] **Firewall Check**: From an external network (outside `192.168.1.0/24`), attempts to access Port 53 or 67/68 are blocked.
- [ ] **Backup Script**: Executing the backup script manually creates a `.tar.gz` file in `/opt/backup/` without permission errors.

---

### Key References & Documentation (For Learning)

- Ubuntu Official DHCP Guide: https://ubuntu.com/server/docs/dhcp
- Ubuntu Official DNS Guide: https://ubuntu.com/server/docs/dns
- ISC DHCP Manual: https://www.isc.org/dhcp/
- BIND9 Administrator Reference Manual: https://www.isc.org/bind/
- Linux File Permissions Explained: https://www.redhat.com/sysadmin/linux-file-permissions-explained
