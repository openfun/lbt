"""Get statements from an LRS."""

from itertools import count
from locust import task

from base import BaseUser
from common.utils import DatasetReader, construct_basic_auth_str
from random import choice
import os
import requests


class GetStatement(BaseUser):
    """User requesting to GET statements from the LRS."""

    first_start = True
    dataset_ids = []

    def on_start(self):
        # Set authentication header for GetStatement client
        self.client.auth_header = construct_basic_auth_str(
            self.environment.parsed_options.lrs_login,
            self.environment.parsed_options.lrs_password,
        )
        # On first start of User
        if GetStatement.first_start:
            GetStatement.first_start = False
            dataset = next(DatasetReader())
            self.dataset_ids = [statement["id"] for statement in dataset]
            url = f"{self.host}/statements"
            auth = (
                self.environment.parsed_options.lrs_login,
                self.environment.parsed_options.lrs_password,
            )
            headers = {"X-Experience-API-Version": "1.0.3"}

            # POST statements in the LRS using requests
            requests.post(url, auth=auth, headers=headers, json=dataset)

    @task
    def statements_get(self):
        """Send GET request to the /statements endpoint."""

        if self.environment.parsed_options.statements_per_req == 1:
            self.client.get(f"/statements?statementId={choice(self.dataset_ids)}")
        else:
            response = self.client.get(
                f"/statements?limit={self.environment.parsed_options.statements_per_req}"
            )

            print(f"{len(response.json()['statements']) =}")
