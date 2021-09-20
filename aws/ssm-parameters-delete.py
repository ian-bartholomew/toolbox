#!/usr/bin/python3

"""Quick script to delete all SSM Parameters"""

import boto3
from colorama import Fore, Style

client = boto3.client("ssm")

response = client.describe_parameters(MaxResults=50)

for param in response["Parameters"]:
    print(Fore.RED + "Deleting: " + Style.RESET_ALL + param["Name"], end=" ...")
    client.delete_parameter(Name=param["Name"])
    print(Fore.GREEN + "DONE" + Style.RESET_ALL)
