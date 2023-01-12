import json

from random import randint

from locust import HttpUser, task


class LearningLocker(HttpUser):
    def __init__(self, *args, **kwargs):

        super().__init__(*args, **kwargs)
        self.client.auth = ("AAA", "BBB")
        self.client.headers.update({"X-Experience-API-Version": "1.0.3"})

    @task
    def statements_post(self):

        payload = []
        dataset = randint(0, 18)
        for line in open(f"/mnt/data/dataset-{dataset:02d}.json"):
            payload += [json.loads(line)]
        self.client.post("/xAPI/statements", json=payload)
