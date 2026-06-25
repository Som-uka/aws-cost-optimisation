# CR: EBS gp2 to gp3 Migration

| Field | Details |
|---|---|
| Change ID | CR-COST-001 |
| Environment | Production |
| Risk Level | Low |
| Status | Complete |

## Description
Migrated 26 EBS volumes (668 GB total) from gp2 to gp3 storage type. gp3 is cheaper per GB and decouples IOPS/throughput from volume size. Performed live with no instance restart.

## Steps Performed
```bash
aws ec2 modify-volume --volume-id <volume-id> --volume-type gp3 --region us-east-1
# Monitor:
aws ec2 describe-volumes-modifications --volume-ids <volume-id> \
  --query 'VolumesModifications[*].{State:ModificationState,Progress:Progress}'
```

## Post-Change Validation
- Each volume confirmed gp3; modification state `completed`
- Instances remained `running` throughout; no downtime

## Rollback Plan
`aws ec2 modify-volume --volume-id <id> --volume-type gp2` (6-hour AWS cooldown applies between modifications).

## Outcome
Success. ~$13/month storage saving, zero downtime.
