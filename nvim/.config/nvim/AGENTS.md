# neovim config

personal neovim configuration built around `lazy.nvim`, fast in-buffer workflows, and behavior close to built-in neovim defaults.

## AGENTS.md

- this file and the `.agents/` directory should follow the progressive disclosure policy
- the top level AGENTS.md should ideally be < 50 lines, and never > 100
- the root AGENTS.md should contain only:
    - one-line project description
    - package manager (if not npm)
    - non-obvious commands only (skip `npm test`, `npm run build` if standard)
    - links to `.agents/rules/` files with brief descriptions
    - verification section (always required)
- remaining instructions should go in `.agents/rules/` files by category (e.g., TypeScript conventions, testing patterns, API design, Git workflow).
- the following content should not go in AGENTS.md nor `.agents/` files:
    - **API documentation** — link to external docs instead
    - **code examples** — agents can infer from reading source files
    - **interface/type definitions** — these exist in the code
    - **generic advice** — "write clean code", "follow best practices"
    - **obvious instructions** — "use TypeScript for .ts files"
    - **redundant info** — things already included in your operating instructions
    - **too vague** — instructions that are not actionable

## Commands

- `stylua .` — format Lua with the repo's `.stylua.toml`
- `scripts/nvim-profile all --runs 3` — benchmark startup plus `gitcommit` and `diff` flows

## Rules

- [architecture](.agents/rules/architecture.md) — configuration entrypoints and module layout
- [editor workflows](.agents/rules/editor-workflows.md) — keymaps, formatting, LSP, filetype behavior, and image pasting
- [tooling and documentation](.agents/rules/tooling-and-documentation.md) — external binaries, XDG behavior, and docs upkeep

## Verification

after making changes:

- reproduce the behavior in an interactive `nvim` session; use a relevant multi-buffer flow when debugging
- `stylua .`
- `nvim --headless -c "quitall"` — secondary syntax/config smoke check
- `scripts/nvim-profile all --runs 3` — when changing startup-sensitive config
