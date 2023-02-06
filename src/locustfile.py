"""LBT entrypoint."""
import json
from random import randint

from locust import HttpUser, events, task


@events.init_command_line_parser.add_listener
def _(parser):
    parser.add_argument(
        "--lrs-login",
        type=str,
        env_var="LOCUST_LRS_LOGIN",
        default="",
        help="Login for LRS basic authentication",
    )
    parser.add_argument(
        "--lrs-password",
        type=str,
        env_var="LOCUST_LRS_PASSWORD",
        default="",
        help="Password for LRS basic authentication",
    )


class BaseUser(HttpUser):
    """Base user simulating requests to the LRS."""

    def on_start(self):
        """Initialize user with basic authentication."""
        self.client.auth = (
            self.environment.parsed_options.lrs_login,
            self.environment.parsed_options.lrs_password,
        )
        self.client.headers.update({"X-Experience-API-Version": "1.0.3"})


class PostStatement(BaseUser):
    """User requesting to POST statements to the LRS."""

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
