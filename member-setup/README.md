## Git Configurator

A cross-platform Bash script that safely applies sensible global Git configurations without overwriting existing settings.

## Prerequisites

**Git must be installed on your machine before running this script.** The script will check for git and exit with instructions if it's not found.

| Platform | Install Command |
| --- | --- |
| macOS | `brew install git` |
| Linux | `sudo apt-get install git` (or your distro's equivalent) |
| Windows | `winget install --id Git.Git -e --source winget` |

## Features

- **Cross-Platform:** Supports Linux, macOS, and Windows.
- **Safe Configuration:** Applies global settings only if they aren't already set (won't overwrite existing credentials or configs).
- **VS Code Integration:** Configures VS Code as the default editor, diff, and merge tool out of the box.

## OS-Specific Execution Instructions

### Linux/macOS
1. Open your terminal.
2. Navigate to the directory where `setup.sh` is saved.
3. Make the script executable:
```bash
chmod +x setup.sh
```
4. Run the script:
```bash
./setup.sh
```

---

### Windows

To run a Bash script on Windows, use **Git Bash** or **WSL**.

1. Right-click inside the folder containing `setup.sh` and select **Git Bash Here**.
2. Run the script:
```bash
bash setup.sh
```

## What Gets Configured?

If any setting is missing from your global Git config (`~/.gitconfig`), the script sets it to these defaults:

| Setting | Value | Description |
| --- | --- | --- |
| `user.name` | Prompted | Your full name |
| `user.email` | Prompted | Email associated with GitHub |
| `init.defaultBranch` | `main` | Sets default branch name for `git init` |
| `core.autocrlf` | `input` | Normalizes line endings (LF on commit) |
| `core.editor` | `code --wait` | Sets VS Code as the commit editor |
| `push.default` | `simple` | Pushes current branch to its upstream counterpart |
| `fetch.prune` | `true` | Automatically prunes deleted remote branches on fetch |
| `rerere.enabled` | `true` | Remembers how conflict resolutions were handled |
| `diff.algorithm` | `histogram` | Modern, accurate diff algorithm |
| `diff.tool` / `merge.tool` | `vscode` | Sets VS Code as default diff and merge tool |
| `credential.helper` | `manager` | Uses Git Credential Manager for secure login |
| `format.pretty` | `%h %ad \| %s%d [%an]` | Readable `git log` output format |
| `log.date` | `short` | Formats dates in logs as `YYYY-MM-DD` |
| `commit.gpgsign` | `true` | Enables automatic GPG signing on commits |
| `pull.rebase` | `false` | Sets default merge behavior for `git pull` |

## Verifying Your Setup

After running the script, verify your global settings at any time:

```bash
git config --list --global
```

---

<div align="center">
  <sub>Built with ❤️ during our academic journey</sub>
</div>