# `command -v` is POSIX portable ✅
# https://stackoverflow.com/a/762682
isinstalled() {
  # cheat a little here
  # we ultimately want the `USER_BIN`s to come first on the `PATH`, which we
  # will do in `zz-user-bin.sh`. but when using `isinstalled` in other files
  # which will be `source`d before `zz-user-bin.sh`, we still want to search
  # the `USER_BIN`s. so just add it in `isinstalled` !
  test "$(PATH="${USER_BIN}:${PATH}" command -v "$1")"
}
