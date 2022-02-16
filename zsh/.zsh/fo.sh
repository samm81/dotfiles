eval "$(register-python-argcomplete pipx)"

# >>> JVM installed by coursier >>>
export JAVA_HOME="/home/maynard/.cache/coursier/jvm/openjdk@1.17.0"
export PATH="$PATH:/home/maynard/.cache/coursier/jvm/openjdk@1.17.0/bin"
# <<< JVM installed by coursier <<<

# >>> coursier install directory >>>
export PATH="$PATH:/home/maynard/.local/share/coursier/bin"
# <<< coursier install directory <<<
