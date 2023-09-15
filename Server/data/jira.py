from dataclasses import dataclass
from datetime import date


@dataclass
class Jira:
    id: int
    site_id: int
    key: str
    title: str
    manager: str
    repoter: str
    urgency: str
    status: str