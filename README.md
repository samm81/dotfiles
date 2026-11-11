### usage

ideally you'll `git clone --recursive-submodules` then `stow` whatever you're
interested in. if you've already `git clone`d, you can `git submodule update
--init --recursive` to get the submodules.

the `agents` package uses submodules as sources for relative links in
`~/.agents/skills`. initialize the submodules before stowing, then restow the
package:

```sh
git submodule update --init --recursive
stow --restow agents
```

`agents/.stow-local-ignore` keeps those source submodules inside the dotfiles
repository instead of linking them into `$HOME`.

### package layout

top-level directories are GNU Stow packages organized around complete setup
units. a package can include supporting files from different configuration
namespaces when they are required for that setup. `stow X` means “set up
everything needed for X”, not “configure only X”.
