import os
import json
import boto3
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    """Lambda handler to trigger ECS task execution."""
    logger.info("Received event: %s", json.dumps(event))

    ecs_client = boto3.client("ecs")

    # Get environment variables
    cluster = os.environ["ECS_CLUSTER"]
    task_definition = os.environ["ECS_TASK_DEFINITION"]
    subnet_ids = os.environ["SUBNET_IDS"].split(",")
    security_group_id = os.environ["SECURITY_GROUP_ID"]

    logger.info(
        "Starting ECS task with cluster: %s, task definition: %s",
        cluster,
        task_definition,
    )

    try:
        # Run the ECS task
        response = ecs_client.run_task(
            cluster=cluster,
            taskDefinition=task_definition,
            launchType="FARGATE",
            networkConfiguration={
                "awsvpcConfiguration": {
                    "subnets": subnet_ids,
                    "securityGroups": [security_group_id],
                    "assignPublicIp": "DISABLED",
                }
            },
        )

        # Get the task ARN from the response
        task_arn = response["tasks"][0]["taskArn"]
        logger.info("Successfully started ECS task: %s", task_arn)

        return {
            "statusCode": 200,
            "body": json.dumps(
                {"message": "ETL task started successfully", "taskArn": task_arn}
            ),
        }

    except Exception as e:
        logger.error("Failed to start ETL task: %s", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps(
                {"message": "Failed to start ETL task", "error": str(e)}
            ),
        }
