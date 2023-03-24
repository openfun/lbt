"""Util functions for locust."""

import json
from uuid import uuid4


class DatasetReader:
    """Read test data from csv file using an iterator."""

    index: int

    def __init__(self):
        self.index = 0

    def __next__(self):
        payload = []
        with open(
            f"/mnt/data/set/dataset-{self.index:04d}.json", encoding="utf8"
        ) as xapi_file:
            for line in xapi_file:
                statement = json.loads(line)
                statement["id"] = str(uuid4())
                payload += [statement]
        self.index += 1
        self.index %= 100
        return payload
