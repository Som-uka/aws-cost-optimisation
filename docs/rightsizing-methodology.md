# Right-Sizing Methodology

Right-sizing is the highest-return, highest-risk cost lever: get it wrong on production and you cause an incident. The discipline is what makes it safe.

## 1. Measure before touching
Pull at least 30 days of CPU and connection metrics. A single busy week is not representative.

```bash
aws cloudwatch get-metric-statistics --namespace AWS/RDS \
  --metric-name CPUUtilization --dimensions Name=DBInstanceIdentifier,Value=<id> \
  --start-time $(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 86400 --statistics Average Maximum --extended-statistics p90
```

## 2. Decide by environment
- **Dev / non-prod:** aggressive downsizing is fine. Near-idle clusters can drop several steps.
- **Production:** one tier at a time, with headroom retained for spikes. Never chase the theoretical minimum.

## 3. Plan the cutover
- Live EBS type changes need no downtime.
- DB class changes cause a brief restart; schedule production changes in a low-traffic window.
- For Aurora writer resizes, plan the failover explicitly so the writer role lands where intended.

## 4. Verify and watch
Confirm the new class is `available`, then monitor CPU/latency for 48 hours. A downsize that causes sustained high CPU should be reverted promptly — the rollback command is trivial and pre-captured.
