#!/usr/bin/python3

"""
quick script to list all access keys for all users
"""
import boto3
from datetime import datetime, timezone

resource = boto3.resource('iam')
client = boto3.client("iam")

for user in resource.users.all():
    for key in user.access_keys.all():

        AccessId = key.access_key_id
        Status = key.status

        print("User:", user.user_name,  "Key:", AccessId, "Status:", Status)
