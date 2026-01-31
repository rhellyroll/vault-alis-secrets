# ALIS Vault — Defense-Grade Secrets Management Platform

**Production-Oriented HashiCorp Vault Deployment Modeling F-35 ALIS Shipboard Operations**

![Vault](https://img.shields.io/badge/Vault-1.21.2-blueviolet?logo=vault)
![RHEL](https://img.shields.io/badge/RHEL-9.5-red?logo=redhat)
![Industry](https://img.shields.io/badge/Industry-Defense%20%26%20Aerospace-blue)

A production-grade HashiCorp Vault implementation demonstrating how F-35 ALIS environments securely manage credentials, cryptographic material, and certificates across sovereign and mission-critical systems.

---

## Executive Summary

### For Hiring Managers and Technical Recruiters

Modern F-35 ALIS (Autonomic Logistics Information System) deployments operate under uniquely constrained conditions:

- Mission-critical operations supporting aircraft maintenance and readiness
- Multi-national sovereignty requiring strict data separation for partner nations
- Export control compliance (ITAR/EAR) governing cryptographic material
- Audit and accountability mandates aligned with Department of Defense controls

This project demonstrates a production-ready secrets management architecture rather than a basic Vault tutorial.

### Business Impact

| Operational Challenge | Solution Demonstrated |
|----------------------|----------------------|
| Hard-coded credentials in maintenance applications | Centralized secrets with controlled access |
| Manual certificate issuance and expiration | Automated PKI with TTL-based lifecycle |
| Limited traceability for privileged access | Immutable, SIEM-ready audit logs |
| Secrets sprawl across multiple systems | Policy-driven RBAC with centralized enforcement |

### Key Differentiators

- Operational focus through systemd integration, backup automation, and health tooling
- Compliance-ready design with auditable access and documented trade-offs
- Defense-specific context modeling ALIS sovereign separation and coalition constraints
- Production patterns including HA-ready design, disaster recovery procedures, and security posture awareness

---

## Architecture Overview

### Logical Vault Architecture (ALIS-Modeled)

┌─────────────────────────────────────────────────────────────┐
│ ALIS Vault Platform │
├─────────────────────────────────────────────────────────────┤
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ │
│ │ Maintenance │ │ Mission │ │ Sovereign │ │
│ │ APIs │ │ Database │ │ Keys │ │
│ │ (KV Engine) │ │ (Dynamic DB) │ │ (KV Engine) │ │
│ └──────────────┘ └──────────────┘ └──────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────┐ │
│ │ PKI Engine (Internal CA) │ │
│ │ • TLS certificates for *.alis.local │ │
│ │ • TTL-controlled issuance and revocation │ │
│ └──────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ ┌──────────────────────────────────────────────────────┐ │
│ │ Audit Subsystem │ │
│ │ • Full request/response logging │ │
│ │ • Immutable, SIEM-ready JSON output │ │
│ └──────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
Sealed using Shamir Secret Sharing
[5 Key Shares | 3 Required to Unseal]


### Deployment Configuration

- Mode: Single-node production baseline (HA-ready design)
- Service management: systemd with restart and failure handling
- Unsealing: Shamir Secret Sharing (5 shares, threshold of 3)
- Storage backend: File-based (designed for Raft or Consul migration)
- Authentication: Token-based with TTL enforcement
- Transport: HTTP (lab); TLS and mTLS required for production

---

## Technology Stack

| Component | Implementation | Production Consideration |
|---------|----------------|--------------------------|
| Operating System | RHEL 9.5 | DoD-approved enterprise Linux |
| Secrets Platform | HashiCorp Vault 1.21.2 | Industry standard |
| Storage | File backend | Raft or Consul for high availability |
| Unsealing | Shamir 5/3 | Auto-unseal via HSM or KMS |
| PKI | Internal CA | Integration with enterprise root CA |
| Audit | Local JSON logs | Forward to centralized SIEM |
| Init System | systemd | Hardened service lifecycle |

---

## Implemented Capabilities

### Core Vault Infrastructure

- Managed as a hardened systemd service
- Explicit initialization and unseal workflow
- Health endpoints suitable for monitoring integration
- Separation of bootstrap credentials from operational access

Evidence: `02-systemd-service.png`

---

### Secrets Engines

#### KV Secrets Engine v2
- Versioned secrets under the `alis/` namespace
- Rollback and version history retention
- Check-and-set protection for concurrent writes

Implemented paths:
alis/maintenance-api
alis/database
alis/sovereign-keys/<nation>


#### PKI Secrets Engine
- Internal Certificate Authority initialization
- Certificate issuance for `*.alis.local`
- TTL-enforced lifecycle and CRL support

Evidence: `05-alis-secrets.png`, `06-secrets-engines.png`

---

### ALIS-Modeled Secrets (Sanitized)

Maintenance API:
Path: alis/maintenance-api
Fields:
api_endpoint
username
password (redacted and rotated)


Mission database:
Path: alis/database
Fields:
host
port
database
credentials (dynamic and rotating)


Sovereign encryption keys:
Path: alis/sovereign-keys/finland
Purpose: Nation-specific encryption material


---

### Security and Compliance Controls

- Least-privilege policy enforcement
- Token TTL and renewal workflows
- Orphan token prevention
- Immutable audit logging

Audit log location:
/var/log/vault/audit.log


Evidence: `09-audit-log.png`

---

### Operational Automation

- `vault-status.sh`: seal state, service health, enabled engines, policies, audit devices
- `backup-secrets.sh`: timestamped disaster recovery backups of secrets and configuration

Evidence: `07-vault-status.png`, `08-backup-execution.png`

---

## Evidence and Validation

| Screenshot | Purpose |
|-----------|--------|
| 01-vault-version.png | Platform verification |
| 02-systemd-service.png | Service management |
| 03-vault-keys.png | Shamir initialization |
| 04-vault-unsealed.png | Operational readiness |
| 05-alis-secrets.png | Secrets retrieval |
| 06-secrets-engines.png | Engine configuration |
| 07-vault-status.png | Health monitoring |
| 08-backup-execution.png | Disaster recovery |
| 09-audit-log.png | Compliance auditing |

Command-line evidence reflects operational environments where graphical interfaces may be restricted.

---

## Security Design and Hardening

### Current (Lab)

| Area | Configuration | Note |
|----|---------------|------|
| Transport | HTTP (localhost) | TLS required in production |
| Unseal | Manual Shamir | Acceptable baseline |
| Storage | File backend | HA requires Raft or Consul |
| Authentication | Bootstrap token | Revoked post-setup |
| Audit | Local JSON | Forward to SIEM |

---

### Production Hardening Roadmap

Phase 1 — Transport Security  
- TLS 1.3
- Mutual TLS for service authentication
- Enterprise CA integration

Phase 2 — High Availability  
- Three-node Vault cluster
- Raft or Consul storage backend
- Disaster recovery replication

Phase 3 — Key Protection  
- HSM integration (FIPS 140-2 Level 3 or higher)
- Auto-unseal via HSM or KMS

Phase 4 — Enterprise Access Control  
- LDAP or Active Directory integration
- OIDC with MFA
- Sentinel governance policies

Phase 5 — Monitoring and Compliance  
- SIEM ingestion and alerting
- Metrics export
- Log immutability (WORM storage)

---

## Compliance Alignment

| Control Family | Coverage |
|---------------|----------|
| AC | Role-based access control |
| AU | Immutable audit logging |
| IA | Token authentication, PKI-ready |
| SC | TLS and certificate lifecycle |
| SI | Secrets versioning and integrity |

Sovereign data separation is enforced through nation-specific paths, policy-controlled access, and auditable cross-domain access attempts.

---

## Repository Structure

alis-vault/
├── README.md
├── docs/
│ ├── screenshots/
│ ├── ARCHITECTURE.md
│ └── RUNBOOK.md
├── scripts/
│ ├── vault-status.sh
│ ├── backup-secrets.sh
│ └── vault-init.sh
├── policies/
│ ├── alis-readonly.hcl
│ ├── alis-admin.hcl
│ └── pki-operator.hcl
└── config/
└── vault.hcl


---

## Key Takeaways for Hiring Managers

This project demonstrates:

- Real-world defense system modeling
- Operational maturity and service ownership
- Security-first architecture and compliance awareness
- Clear documentation supported by operational evidence
- Deliberate design trade-offs with a production hardening roadmap

---

## Technical Discussion Topics

- Shamir unseal versus auto-unseal trade-offs
- High-availability storage backends
- PKI lifecycle automation
- Vault Agent integration patterns
- Disaster recovery testing and RPO/RTO planning
- Zero-trust alignment
- Secrets rotation strategies

---

## License

This project is for educational and portfolio demonstration purposes.  
HashiCorp Vault is a product of HashiCorp, Inc.

---

Built with precision. Designed for defense. Ready for production.
