from dataclasses import dataclass
from datetime import date


@dataclass
class Site:
    id: int
    name: str
    url: str