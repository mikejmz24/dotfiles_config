from collections.abc import Iterator
from typing import overload
from typing_extensions import Self

class Range:
    start: int | None
    end: int | None
    @overload
    def __init__(self, start: None, end: None): ...
    @overload
    def __init__(self, start: int, end: int | None): ...
    def range_for_length(self, length: int | None) -> tuple[int, int] | None: ...
    def content_range(self, length: int | None) -> ContentRange | None: ...
    def __iter__(self) -> Iterator[int | None]: ...
    @classmethod
    def parse(cls, header: str | None) -> Self: ...

class ContentRange:
    start: int | None
    stop: int | None
    length: int | None
    @overload
    def __init__(self, start: None, stop: None, length: int | None): ...
    @overload
    def __init__(self, start: int, stop: int, length: int | None): ...
    def __iter__(self) -> Iterator[int | None]: ...
    @classmethod
    def parse(cls, value: str | None) -> Self: ...