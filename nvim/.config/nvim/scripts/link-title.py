#!/usr/bin/env python3
import subprocess
import sys
from html.parser import HTMLParser


class TitleParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.in_title = False
        self.done = False
        self.parts: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag == "title" and not self.done:
            self.in_title = True

    def handle_endtag(self, tag: str) -> None:
        if tag == "title" and self.in_title:
            self.in_title = False
            self.done = True

    def handle_data(self, data: str) -> None:
        if self.in_title:
            self.parts.append(data)


def main() -> int:
    result = subprocess.run(
        ["curl", "--fail", "--silent", "--show-error", "--location", "--max-time", "10",
         "--max-filesize", "2097152", "--proto", "=http,https", "--proto-redir", "=http,https",
         "--user-agent", "Mozilla/5.0", "--", sys.argv[1]],
        capture_output=True,
        check=False,
    )
    if result.returncode:
        return 1
    parser = TitleParser()
    parser.feed(result.stdout.decode("utf-8", errors="replace"))
    title = " ".join("".join(parser.parts).split())
    if not parser.done or not title:
        return 1
    print(title)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
