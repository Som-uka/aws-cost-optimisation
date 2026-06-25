#!/usr/bin/env bash
#
# audit-rds-utilisation.sh
# Pulls 30-day CPU and connection statistics for an RDS/Aurora instance to
# support an evidence-based right-sizing decision. Reports Average, Maximum,
# and p90 so a downsize is justified by data, not guesswork.
#
# Usage: ./audit-rds-utilisation.sh <db-instance-identifier> <region>
set -euo pipefail
DB_ID="${1:?db instance identifier required}"
REGION="${2:-us-east-1}"
START=$(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ)
END=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "==> CPUUtilization (30d) for $DB_ID"
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value="$DB_ID" \
  --start-time "$START" --end-time "$END" \
  --period 86400 --statistics Average Maximum --extended-statistics p90 \
  --region "$REGION" \
  --query 'Datapoints | sort_by(@,&Timestamp)[-7:]' --output table

echo "==> DatabaseConnections (30d) for $DB_ID"
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS --metric-name DatabaseConnections \
  --dimensions Name=DBInstanceIdentifier,Value="$DB_ID" \
  --start-time "$START" --end-time "$END" \
  --period 86400 --statistics Average Maximum \
  --region "$REGION" \
  --query 'Datapoints | sort_by(@,&Timestamp)[-7:]' --output table

echo "==> Rule of thumb: sustained Average < 10% with low max connections = downsize candidate."
