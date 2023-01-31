"""LBT entrypoint."""
import json
from random import randint

from locust import HttpUser, task


class LearningLocker(HttpUser):
    """User simulating requests to the LearningLocker LRS."""

    def __init__(self, *args, **kwargs):
        """Initialize user with basic authentication."""
        super().__init__(*args, **kwargs)
        self.client.auth = ("AAA", "BBB")
        self.client.headers.update({"X-Experience-API-Version": "1.0.3"})

    @task
    def statements_post(self):
        """Send POST request to the /xAPI/statements endpoint."""
        payload = []
        dataset = randint(0, 18)
        with open(
            f"/mnt/data/dataset-{dataset:02d}.json", encoding="utf8"
        ) as xapi_file:
            for line in xapi_file:
                payload += [json.loads(line)]
        self.client.post("/xAPI/statements", json=payload)
