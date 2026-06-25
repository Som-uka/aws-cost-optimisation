# Savings Summary

Verified monthly savings from the first optimisation phase: **~$1,588/month (~$19,056/year)**, delivered with zero production downtime.

| Change | Method | Monthly Saving |
|---|---|---|
| Production DB right-size | One-tier downsize after percentile analysis | Largest single item |
| Dev DB right-size | Two-step downsize (confirmed ~2% avg CPU) | ~$406 |
| Scheduled dev DB stop/start | Off outside business hours, weekdays only | Significant dev compute |
| EBS gp2 → gp3 (26 vols, 668 GB) | Live modify, no downtime | ~$13 |
| Orphaned EBS cleanup (250 GB) | Snapshot then delete | Recurring charge removed |
| Aurora Auto Scaling threshold | Raised 50% → 80% to stop transient scale-out | Avoided needless reader spend |

## Context
The environment's monthly bill was in the ~$13K range, with a single database engine accounting for over half of total spend. That concentration is why database right-sizing delivered the bulk of the savings: optimising the largest line item first is where the return is.

## Principle
Every figure here is from verified, executed change, not projected. Savings claims that cannot be tied to an actual change are not counted.
