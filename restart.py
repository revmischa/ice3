#!/usr/bin/env python

import boto3

session = boto3.Session(profile_name='mish')
client = session.client('ecs')
CLUSTER = 'klulz'


def restart_service(service):
    taskdef = service['taskDefinition']
    sarn = service['serviceArn']

    res = client.list_tasks(
        cluster=CLUSTER,
    )
    task_arns = res['taskArns']

    for tarn in task_arns:
        # scale down
        print("Stopping", tarn)
        client.stop_task(
            cluster=CLUSTER,
            task=tarn,
            reason="restarting...",
        )

    if task_arns:
        waiter = client.get_waiter('tasks_stopped')
        print("Waiting on", task_arns)
        waiter.wait(
            cluster=CLUSTER,
            tasks=task_arns,
        )

    # scale up
    # res = client.run_task(
    #     cluster=CLUSTER,
    #     taskDefinition=taskdef,
    # )
    # started_tasks = res['tasks']
    # task_arns = [t['taskArn'] for t in started_tasks]
    print("Starting...", task_arns)

    waiter = client.get_waiter('tasks_running')
    waiter.wait(
        cluster=CLUSTER,
        tasks=task_arns,
    )
    print("Task started")

if __name__ == '__main__':
    # get service
    services = client.list_services(
        cluster=CLUSTER
    )['serviceArns']

    # get task
    services_info = client.describe_services(
        cluster=CLUSTER,
        services=services
    )

    for svc in services_info['services']:
        restart_service(svc)
