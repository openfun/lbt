"""LBT entrypoint."""

from locust import FastHttpUser, events
from typing import Union


@events.init_command_line_parser.add_listener
def _(parser):
    parser.add_argument(
        "--statements-per-req",
        type=int,
        env_var="STATEMENTS_PER_REQ",
        default="",
        help="Number of statements to post/get per request",
    )


class BaseUser(FastHttpUser):
    """Base user simulating requests to the LRS."""

    profiles: bytes
    personae: dict
    alignments: Union[None, dict]
    parameters: dict

    abstract = True
    default_headers = {"X-Experience-API-Version": "1.0.3"}

    def __init__(self, environment):
        """Initialize datasim parameters for generation."""
        super().__init__(environment)
        with open("data/profiles.json", "rb") as f:
            self.profiles = f.read()

        self.personae = {
            "name": "trainees",
            "objectType": "Group",
            "member": [
                {
                    "name": "John Doe",
                    "mbox": "mailto:john.doe@example.org",
                    "role": "Lead Developer",
                }
            ],
        }

        self.parameters = {
            "start": "2022-01-16T08:38:39.219768Z",
            "timezone": "Europe/Paris",
            "max": self.environment.parsed_options.statements_per_req,
            "seed": 42,
            "from": "2022-01-16T08:38:39.219768Z",
        }

        self.alignments = None
