# editor workflows

- keep behavior close to built-in vim/neovim defaults; avoid unnecessary plugins or abstractions.
- never override existing keybindings; check for conflicts before adding or changing a map.
- prefer two-character `<leader>` namespaces; use reminder mappings when a rename should be non-disruptive.
- keep LSP mappings on the `gr*` prefix when adding or adjusting them.
- optimize for in-buffer workflows; manual formatting must not require saving.
