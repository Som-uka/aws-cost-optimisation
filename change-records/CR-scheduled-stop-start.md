# CR: Scheduled Stop/Start for Non-Production DB

| Field | Details |
|---|---|
| Change ID | CR-COST-003 |
| Environment | Dev |
| Risk Level | Low |
| Status | Complete |

## Description
Deployed an EventBridge Scheduler + Lambda automation to stop a non-production Aurora cluster outside business hours and start it again each weekday morning, cutting its compute cost to roughly a third of 24/7 baseline.

## Steps Performed
```bash
# Stop 18:00 weekdays
aws scheduler create-schedule --name dev-db-stop \
  --schedule-expression "cron(0 18 ? * MON-FRI *)" \
  --schedule-expression-timezone "America/Chicago" \
  --flexible-time-window '{"Mode":"OFF"}' \
  --target '{"Arn":"<lambda-arn>","RoleArn":"<role-arn>","Input":"{\"action\":\"stop\"}"}'
# Start 07:00 weekdays — same pattern, action=start
```
(Lambda source: scripts/db-stop-start-lambda.py)

## Post-Change Validation
- Confirmed cluster stops at scheduled evening time and starts next weekday morning
- Verified production clusters explicitly excluded from the schedule

## Rollback Plan
`aws scheduler delete-schedule --name dev-db-stop` (and the start schedule); cluster left running.

## Outcome
Success. Significant dev compute saving with no production impact.
