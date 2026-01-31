#!/bin/bash
# Backup Vault secrets for disaster recovery


# Set Vault address and token
export  VAULT_ADDR='http://127.0.0.1:8200'
VAULT_TOKEN=$(grep 'Initial Root Token:' ~/vault-keys.txt | awk '{print $NF}') 
export VAULT_TOKEN

# Create directory with timestamp
TIMESTAMP=$(date +%Y%m%d%=%H%M%S) 
BACKUP_DIR="/tmp/vault-backup-${TIMESTAMP}"
mkdir -p "$BACKUP_DIR"

echo "========================================="
echo "Vault Backup - F-35 ALIS Secrets"
echo "========================================="
echo ""
echo "Backing up Vault secrets to: $BACKUP_DIR"
echo ""

# Export ALIS secrets
vault kv get -format=json alis/maintenance-api > "$BACKUP_DIR/maintenance-api.json" 2>/dev/null && echo "maintenance-api"
vault kv get -format=json alis/database > "$BACKUP_DIR/database.json"  2>/dev/null && echo "database"
vault kv get -format=json alis/sovereign-keys/finland > "$BACKUP_DIR/finland-keys.json" 2>/dev/null "finland-keys"

echo ""
echo "Backing up configuration files..."

# Backup configuration
cp ~/vault-keys.txt "$BACKUP_DIR/" 2>/dev/null


# Create archive
tar -czf "$BACKUP_DIR.tar.gz" -C /tmp "$(basename $BACKUP_DIR)"
echo "Backup created: $BACKUP_DIR.tar.gz"
echo "Size: $(du -h $BACKUP_DIR.tar.gz | cut -f1)"


# Cleanup temporary directory
rm -rf "$BACKUP_DIR"

