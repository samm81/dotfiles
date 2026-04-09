## user's preferences

- the user's writing style is lowercase (except for "I" and "I'm")
- you should still capitalize the words "I" and "I'm" !! do not write "i" or "i'm" !!
- do! not! write! "i" !!!! do! not!! write!!! "i'm" !!!!

## git commits

- always add yourself as a co-author on every git commit you make by ending the commit message with a blank line, then `Co-authored-by: <current-model>`
- determine <current-model> from the codex harness/instructions only (not shell env vars or config files)
- example: `Co-authored-by: gpt-5.3-codex`

## AGENTS.md

all AGENTS.md files should be kept up to date when making changes to the repo.

## tools

- `ast-grep` is installed. for any code search that requires understanding of syntax or code structure, you should default to using `ast-grep --lang [language] -p '<pattern>'` . adjust the --lang flag as needed for the specific programming language. avoid using text-only search tools unless a plain-text search is explicitly requested.
