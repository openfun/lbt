"""Post statements to an LRS."""

from common.utils import DatasetReader
from locust import task

from base import BaseUser

dataset = DatasetReader()


class PostGet(BaseUser):
    """User requesting to POST statements to the LRS, then GET them."""

    @task
    def statements_post(self):
        """Send POST request to the statements endpoint."""
        self.client.post("/statements", json=next(dataset))

    @task
    def statements_get(self):
        """Send GET request to the /xAPI/statements endpoint."""
        self.client.get("/data/xAPI/statements")
