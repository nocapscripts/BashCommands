# archcommands.bash

A collection of simplified shell commands for Arch Linux — package management, file utilities, git shortcuts, system monitoring, and more.

---

## Installation

> **Requires bash** — will not work with `sh` or `dash`.

```bash 
sudo mkdir -p ~/Commands
```

### 1. Copy the file to your Commands folder

```bash
sudo cp archcommands.bash ~/Commands/archcommands.bash
```

### 2. Source it in your ~/.bashrc

```bash
echo 'source ~/Commands/archcommands.bash' >> ~/.bashrc
```

### 3. Reload your shell

```bash
source ~/.bashrc
```

### Verify it works

```bash
cmds
```

This prints the full command cheat sheet.

---

## Troubleshooting

**Syntax error near unexpected token `(`**
You are sourcing the file with `sh` instead of `bash`. Make sure your shell is bash:
```bash
echo $SHELL   # should say /bin/bash
chsh -s /bin/bash
```
Then open a new terminal and try again.

**Permission denied copying to ~/Commands/**
```bash
sudo chown $USER:$USER ~/Commands
```

---

## Command Reference

### Packages
| Command | Description |
|---|---|
| `install <pkg>` | Install a package |
| `remove <pkg>` | Remove package + unused deps |
| `update` | Full system update |
| `search <term>` | Search package repos |
| `info <pkg>` | Package details |
| `installed` | List explicitly installed packages |
| `owns <file>` | Which package owns a file |
| `clean` | Clear old package cache |

### Files
| Command | Description |
|---|---|
| `up [n]` | Go up N directories (default 1) |
| `mkcd <dir>` | Create directory and cd into it |
| `ff <name>` | Find file by name |
| `fgrep <text>` | Find file by content |
| `dsize [dir]` | Directory size |
| `lsize [dir]` | List sizes of all items |
| `extract <archive>` | Extract any archive format |
| `backup <file>` | Create a dated backup of a file |

### Web / Search
| Command | Description |
|---|---|
| `google <query>` | Search Google in browser |
| `duck <query>` | Search DuckDuckGo in browser |
| `archwiki <query>` | Search the Arch Wiki |
| `aursearch <query>` | Search the AUR |
| `weather [city]` | Current weather via wttr.in |
| `myip` | Your public IP address |
| `isup <url>` | Check if a site is reachable |

### System
| Command | Description |
|---|---|
| `sysinfo` | CPU / RAM / Disk / Uptime overview |
| `ports` | Show open ports |
| `errors` | Journal errors from current boot |
| `log` | Follow system journal live |

### Services
| Command | Description |
|---|---|
| `sstart <svc>` | Start a service |
| `sstop <svc>` | Stop a service |
| `srestart <svc>` | Restart a service |
| `sstatus <svc>` | Show service status |
| `senable <svc>` | Enable + start a service |
| `sdisable <svc>` | Disable + stop a service |

### Git
| Command | Description |
|---|---|
| `gs` | git status |
| `ga` | git add -A |
| `gc` | git commit -m |
| `gp` | git push |
| `gl` | git log (oneline graph, last 10) |
| `gd` | git diff |
| `gcp <message>` | Add + commit + push to main |
| `gremote <url>` | Add origin remote |
| `gupstream <url>` | Add upstream remote |
| `gpupmain` | Force push main to upstream |
| `repoc <name> [--public\|--private]` | Create a new GitHub repo |

### Misc
| Command | Description |
|---|---|
| `reload` | Reload ~/.bashrc |
| `hist <term>` | Search command history |
| `cmds` | Show this cheat sheet |
