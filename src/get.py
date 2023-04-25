"""Get statements from an LRS."""

import requests
from base import BaseUser
from locust import task

from common.utils import generate_dataset


class GetStatement(BaseUser):
    """User requesting to GET statements from the LRS."""

    first_start = True
    dataset_ids = []

    def on_start(self):
        # On first start of User
        if GetStatement.first_start:
            GetStatement.first_start = False

            self.parameters.update(
                {
                    "max": self.environment.parsed_options.statements_per_req * 100,
                }
            )

            dataset = generate_dataset(
                self.profiles, self.personae, self.alignments, self.parameters
            )

            # POST statements in the LRS without triggering locust measurement
            requests.post(
                f"{self.host}/statements",
                auth=("AAA", "BBB"),
                headers={"X-Experience-API-Version": "1.0.3"},
                data=dataset,
            )

    @task
    def statements_get(self):
        """Send GET request to the /statements endpoint."""

        self.client.get(
            f"/statements?limit={self.environment.parsed_options.statements_per_req}"
        )
