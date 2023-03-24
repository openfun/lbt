"""Get statements from an LRS."""

from locust import task

from base import BaseUser


class GetStatement(BaseUser):
    """User requesting to GET statements from the LRS."""

    @task
    def statements_get(self):
        """Send GET request to the /xAPI/statements endpoint."""
        self.client.get("/data/xAPI/statements")
