#!/usr/bin/env python

import boto3

session = boto3.Session(profile_name='mish')
client = session.client('ecs')
CLUSTER = 'klulz'


def restart_service(service):
    res = client.list_tasks(
        cluster=CLUSTER,
    )
    task_arns = res['taskArns']
    if not task_arns:
        print("Failed to get task_arns :(")
        return []

    for tarn in task_arns:
        # scale down
        print("Stopping", tarn)
        client.stop_task(
            cluster=CLUSTER,
            task=tarn,
            reason="restarting...",
        )

    waiter = client.get_waiter('tasks_stopped')
    print("Waiting on", task_arns)
    waiter.wait(
        cluster=CLUSTER,
        tasks=task_arns,
    )
    return task_arns


def wait_on_tasks(task_arns):
    if not task_arns:
        return
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

    task_arns = []
    for svc in services_info['services']:
        tarns = restart_service(svc)
        task_arns.extend(tarns)

    print("Starting...", task_arns)
    wait_on_tasks(task_arns)
