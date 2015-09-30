import re
import os.path

c = get_config()

lines = []
for rcfile in ["~/.personalconfig/zshaliases.rc", "~/.zshrc-work", "~/.xrc-work"]:
    with open(os.path.expanduser(rcfile)) as f:
        lines += f.readlines()

aliases = []
for line in lines:
    if line.startswith('alias -s'):
        # TODO: Handle suffix aliases (-s)
        pass
    elif line.startswith('alias -s'):
        # TODO: Handle global aliases (-g)
        pass
    if line.startswith('alias'):
        parts = re.match(r"""^alias (\w+)=(['"]?)(.+)\2$""", line.strip())
        if parts:
            source, _, target = parts.groups()
            aliases.append((source, target))


c.AliasManager.user_aliases = aliases
