#!/usr/bin/env bash
#
# find-orphaned-resources.sh
# Surfaces cost leaks: unattached EBS volumes, unassociated Elastic IPs,
# and old snapshots. Read-only — reports only, deletes nothing.
#
# Usage: ./find-orphaned-resources.sh <region>
set -euo pipefail
REGION="${1:-us-east-1}"

echo "==> Unattached (available) EBS volumes:"
aws ec2 describe-volumes --filters Name=status,Values=available \
  --region "$REGION" \
  --query 'Volumes[*].{ID:VolumeId,Size:Size,AZ:AvailabilityZone,Created:CreateTime}' \
  --output table

echo "==> Unassociated Elastic IPs (these bill while idle):"
aws ec2 describe-addresses --region "$REGION" \
  --query 'Addresses[?AssociationId==null].{IP:PublicIp,AllocId:AllocationId}' \
  --output table

echo "==> Self-owned snapshots older than 1 year:"
CUTOFF=$(date -u -d '1 year ago' +%Y-%m-%d)
aws ec2 describe-snapshots --owner-ids self --region "$REGION" \
  --query "Snapshots[?StartTime<='$CUTOFF'].{ID:SnapshotId,Size:VolumeSize,Started:StartTime}" \
  --output table
