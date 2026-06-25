# CR: Database Instance Right-Sizing

| Field | Details |
|---|---|
| Change ID | CR-COST-002 |
| Environment | Production + Dev |
| Risk Level | Medium (prod), Low (dev) |
| Status | Complete |

## Description
Downsized two database instances after a 30-day utilisation audit. Dev instance averaged ~2% CPU (max < 17%) and was downsized two effective steps; the production writer was downsized one tier, followed by a controlled manual failover to restore the correct writer role.

## Basis (Evidence)
- Dev: 30-day Average CPU ~2%, Maximum ~16.8%; connections avg 11–17, max 47
- Prod: percentile analysis supported a one-tier reduction with headroom retained

## Steps Performed
```bash
aws rds modify-db-instance --db-instance-identifier <dev-id> \
  --db-instance-class db.r5.large --apply-immediately
aws rds modify-db-instance --db-instance-identifier <prod-id> \
  --db-instance-class <one-tier-smaller> --apply-immediately
# Prod: manual failover in a low-traffic window to restore writer role
aws rds failover-db-cluster --db-cluster-identifier <prod-cluster>
```

## Post-Change Validation
- Both instances `available` at the new class
- Prod writer/reader roles confirmed correct after failover
- CPU headroom monitored for 48h post-change

## Rollback Plan
Re-issue modify-db-instance with the original class; failover again if needed.

## Outcome
Success. Largest single saving of the programme; dev resize alone ~$406/month.
