"""LBT entrypoint."""

from locust import FastHttpUser, events


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

    abstract = True
    default_headers = {"X-Experience-API-Version": "1.0.3"}
