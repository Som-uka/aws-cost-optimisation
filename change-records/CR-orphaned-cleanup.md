# CR: Orphaned Resource Cleanup

| Field | Details |
|---|---|
| Change ID | CR-COST-004 |
| Environment | Production |
| Risk Level | Low |
| Status | Complete |

## Description
Removed two orphaned, unattached EBS volumes (250 GB combined) that were no longer in use but still accruing storage charges. Each was snapshotted before deletion as a safety net.

## Steps Performed
```bash
# Identify
aws ec2 describe-volumes --filters Name=status,Values=available \
  --query 'Volumes[*].{ID:VolumeId,Size:Size}' --output table
# Snapshot, then delete
aws ec2 create-snapshot --volume-id <id> --description "Pre-deletion safety snapshot"
aws ec2 delete-volume --volume-id <id>
```

## Post-Change Validation
- Snapshots confirmed `completed` before any deletion
- Volumes confirmed removed; no instance dependency existed

## Rollback Plan
Recreate volume from the retained snapshot: `aws ec2 create-volume --snapshot-id <snap>`.

## Outcome
Success. Ongoing storage charge for 250 GB removed; snapshots retained as recovery point.
