#!/bin/bash
# Vault Status Dashboard for F-35 ALIS

# Set Vault address
export VAULT_ADDR='http://127.0.0.1:8200'

# Login with root token
VAULT_TOKEN=$(grep 'Initial Root Token:' ~/vault-keys.txt | awk '{print $NF}') 


echo "==========================================="
echo "HashiCorp Vault - F-35 ALIS Secrets Lab"
echo "==========================================="
echo ""


# Vault status
echo "[1] Vault Status:"
vault status 2>&1 | head -12
echo ""


# Service status
echo "[2] Service Status:"
systemctl is-active vault.service && echo " vault.service: active" ||
echo " vault.service: inactive"
echo ""

# Secrets engines
echo "[3] Enabled Secrets Engines:"
vault secrets list 2>/dev/null | grep -E "alis|pki" 
echo ""

# ALIS secrets
echo "[4] ALIS Secrets:"
vault kv list alis/ 2>/dev/null
echo ""


# Policies
echo "[5] Policies:"
vault policy list 2>/dev/null 
echo ""


# Audit devices
echo "[6] Audit Logging:"
vault audit list 2>/dev/null
echo ""


# Storage usage
echo "[7] Storage Usage:"
du -sh /opt/vault/data 2>/dev/null 
echo ""


echo "========================================================="

