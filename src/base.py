"""LBT entrypoint."""

from locust import FastHttpUser, events

from common.utils import construct_basic_auth_str


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

    def on_start(self):
        """Initialize user with basic authentication."""
        self.client.auth_header = construct_basic_auth_str(
            self.environment.parsed_options.lrs_login,
            self.environment.parsed_options.lrs_password,
        )
