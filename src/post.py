"""Post statements to an LRS."""

from common.utils import SingletonMeta, generate_dataset
import names
from locust import task

from base import BaseUser


# Each user at each requests needs a new seed
class Seed(metaclass=SingletonMeta):
    index: int = 0

    def increment_seed(self):
        """Increment seed and return it."""
        self.index += 1
        return self.index


class PostStatement(BaseUser):
    """User requesting to POST statements to the LRS."""

    def on_start(self):
        """Retrieve inputs for data generation."""

        # Set the personae for this user
        full_name = names.get_full_name()
        self.personae.update(
            {
                "member": [
                    {
                        "name": full_name,
                        "mbox": f"mailto:{full_name.replace(' ', '.')}@example.org",
                        "role": "Lead Developer",
                    }
                ],
            }
        )

    @task
    def statements_post(self):
        """Send POST request to the statements endpoint."""
        # Set parameters for datasim generation
        # with the seed corresponding to the current request number
        self.parameters.update(
            {
                "seed": Seed().increment_seed(),
            }
        )

        dataset = generate_dataset(
            self.profiles, self.personae, self.alignments, self.parameters
        )

        self.client.post(
            "/statements",
            data=dataset,
            headers={"Content-type": "application/json", "Accept": "text/plain"},
        )
