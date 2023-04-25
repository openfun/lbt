"""Util functions for locust."""

import json
import requests

from typing import Union
from uuid import uuid4
from os.path import exists


def generate_dataset(
    profiles: bytes,
    personae: dict,
    alignments: Union[None, dict],
    parameters: dict,
) -> bytes:
    """POST to datasim server and return generated dataset."""

    # Request datasim server a dataset generation
    resp = requests.post(
        "http://datasim:9090/api/v1/generate",
        files={
            "profiles": (None, profiles),
        },
        data={
            "personae-array": json.dumps([personae]),
            "parameters": json.dumps(parameters),
            "alignments": "" if alignments is None else json.dumps(alignments),
        },
        auth=("admin", "funfunfun"),
    )

    # Add a comma at the end of each statement but the last
    return resp.content.replace(b"}\n{", b"},\n{")


class DatasetReader:
    """Read test data from csv file using an iterator."""

    index: int

    def __init__(self):
        self.index = 0

    def __next__(self):
        payload = []
        if not exists(f"/app/data/set/dataset-{self.index:04d}.json"):
            self.index = 0
        file_path = f"/app/data/set/dataset-{self.index:04d}.json"
        with open(file_path, encoding="utf8") as xapi_file:
            for line in xapi_file:
                statement = json.loads(line)
                statement["id"] = str(uuid4())
                payload += [statement]
        self.index += 1
        return payload


class SingletonMeta(type):
    """
    The Singleton class implemented using metaclass.
    """

    _instances = {}

    def __call__(cls, *args, **kwargs):
        """
        Possible changes to the value of the `__init__` argument do not affect
        the returned instance.
        """
        if cls not in cls._instances:
            instance = super().__call__(*args, **kwargs)
            cls._instances[cls] = instance
        return cls._instances[cls]
