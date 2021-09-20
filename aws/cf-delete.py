#!/usr/bin/python3

"""
Script to delete all of the CloudFormation stacks in an account.
This will loop until all of them are deleted, with an exponental
backoff.
"""
import boto3
from time import sleep
from colorama import Fore, Style

client = boto3.client("cloudformation")
cloudformation = boto3.resource("cloudformation")

MAX_WAIT_TIME = 45


def get_stacks():
    return client.list_stacks(
        StackStatusFilter=[
            "CREATE_IN_PROGRESS",
            "CREATE_FAILED",
            "CREATE_COMPLETE",
            "ROLLBACK_IN_PROGRESS",
            "ROLLBACK_FAILED",
            "ROLLBACK_COMPLETE",
            "DELETE_IN_PROGRESS",
            "DELETE_FAILED",
            #  "DELETE_COMPLETE",
            "UPDATE_IN_PROGRESS",
            "UPDATE_COMPLETE_CLEANUP_IN_PROGRESS",
            "UPDATE_COMPLETE",
            "UPDATE_FAILED",
            "UPDATE_ROLLBACK_IN_PROGRESS",
            "UPDATE_ROLLBACK_FAILED",
            "UPDATE_ROLLBACK_COMPLETE_CLEANUP_IN_PROGRESS",
            "UPDATE_ROLLBACK_COMPLETE",
            "REVIEW_IN_PROGRESS",
            "IMPORT_IN_PROGRESS",
            "IMPORT_COMPLETE",
            "IMPORT_ROLLBACK_IN_PROGRESS",
            "IMPORT_ROLLBACK_FAILED",
            "IMPORT_ROLLBACK_COMPLETE",
        ],
    )


# for incremental back off
def get_wait_time_exp(retry_count):
    if retry_count == 0:
        return 0
    return pow(2, retry_count)


response = get_stacks()
retry_count = 0
stacks = 1
while stacks > 0:
    wait_time = min(get_wait_time_exp(retry_count), MAX_WAIT_TIME)
    print(Fore.RED + "Deleting:" + Style.RESET_ALL)
    for stack_summary in response["StackSummaries"]:
        stack = cloudformation.Stack(stack_summary["StackName"])
        print(stack.name, end="...")
        stack.delete()
        sleep(wait_time)
        print(Fore.GREEN + "DONE" + Style.RESET_ALL)
    response = get_stacks()
    stacks = len(response["StackSummaries"])
    retry_count = retry_count + 1
