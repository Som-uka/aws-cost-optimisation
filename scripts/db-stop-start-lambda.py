"""
db-stop-start-lambda.py

Lambda function to stop or start a non-production Aurora/RDS cluster on a
schedule, driven by EventBridge Scheduler. Cuts compute cost for clusters
that do not need to run outside business hours.

Event payload:
    {"action": "stop"}   or   {"action": "start"}

Environment variables:
    CLUSTER_ID  - the DB cluster identifier to control

IAM (least privilege) for the execution role:
    rds:StopDBCluster, rds:StartDBCluster, rds:DescribeDBClusters
    on the specific cluster ARN only.

Note: production clusters are deliberately NOT controlled by this function.
A morning warm-up delay is acceptable for dev, not for production.
"""
import os
import boto3

rds = boto3.client("rds")
CLUSTER_ID = os.environ["CLUSTER_ID"]


def lambda_handler(event, context):
    action = (event or {}).get("action")

    # Guard: only act on a known cluster, only on known actions
    if action not in ("stop", "start"):
        raise ValueError(f"Unsupported action: {action!r} (expected 'stop' or 'start')")

    status = _current_status()

    if action == "stop":
        if status == "available":
            rds.stop_db_cluster(DBClusterIdentifier=CLUSTER_ID)
            result = "stopping"
        else:
            result = f"skipped (status={status})"
    else:  # start
        if status == "stopped":
            rds.start_db_cluster(DBClusterIdentifier=CLUSTER_ID)
            result = "starting"
        else:
            result = f"skipped (status={status})"

    return {"cluster": CLUSTER_ID, "action": action, "result": result}


def _current_status():
    resp = rds.describe_db_clusters(DBClusterIdentifier=CLUSTER_ID)
    return resp["DBClusters"][0]["Status"]
