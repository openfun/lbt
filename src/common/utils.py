"""Util functions for locust."""

import json
from base64 import b64encode
from uuid import uuid4
from os.path import exists


def construct_basic_auth_str(username, password):
    """Construct Authorization header value to be used in HTTP Basic Auth"""
    if isinstance(username, str):
        username = username.encode("latin1")
    if isinstance(password, str):
        password = password.encode("latin1")
    return "Basic " + b64encode(b":".join((username, password))).strip().decode("ascii")


class DatasetReader:
    """Read test data from csv file using an iterator."""

    index: int

    def __init__(self):
        self.index = 0

    def __next__(self):
        payload = []
        if not exists(f"/mnt/data/set/dataset-{self.index:04d}.json"):
            self.index = 0
        file_path = f"/mnt/data/set/dataset-{self.index:04d}.json"
        with open(file_path, encoding="utf8") as xapi_file:
            for line in xapi_file:
                statement = json.loads(line)
                statement["id"] = str(uuid4())
                payload += [statement]
        self.index += 1
        return payload
