"""LBT entrypoint."""

from base64 import b64encode
from locust import FastHttpUser, events

from common.utils import DatasetReader


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


def _construct_basic_auth_str(username, password):
    """Construct Authorization header value to be used in HTTP Basic Auth"""
    if isinstance(username, str):
        username = username.encode("latin1")
    if isinstance(password, str):
        password = password.encode("latin1")
    return "Basic " + b64encode(b":".join((username, password))).strip().decode("ascii")


class BaseUser(FastHttpUser):
    """Base user simulating requests to the LRS."""

    abstract = True
    default_headers = {"X-Experience-API-Version": "1.0.3"}

    def on_start(self):
        """Initialize user with basic authentication."""
        self.client.auth_header = _construct_basic_auth_str(
            self.environment.parsed_options.lrs_login,
            self.environment.parsed_options.lrs_password,
        )
