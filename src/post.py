"""Post statements to an LRS."""

from common.utils import DatasetReader
from locust import task

from base import BaseUser

dataset = DatasetReader()


class PostStatement(BaseUser):
    """User requesting to POST statements to the LRS."""

    @task
    def statements_post(self):
        """Send POST request to the statements endpoint."""
        self.client.post("/statements", json=next(dataset))
