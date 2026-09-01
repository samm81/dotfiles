### usage

ideally you'll `git clone --recursive-submodules` then `stow` whatever you're
interested in. if you've already `git clone`d, you can `git submodule update
--init --recursive` to get the submodules.

### package layout

top-level directories are GNU Stow packages organized around complete setup
units. a package can include supporting files from different configuration
namespaces when they are required for that setup. `stow X` means “set up
everything needed for X”, not “configure only X”.
