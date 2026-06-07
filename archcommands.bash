#!/usr/bin/env bash
##############################################################
#  Arch Linux — Custom Simplified Commands
#  Add to your ~/.bashrc:  source ~/arch_commands.bash
#  or paste directly into ~/.bashrc
##############################################################


# ── Package Management (pacman + yay wrappers) ─────────────

# Install a package
install() { sudo pacman -S "$@"; }

# Remove a package (and unused deps)
remove() { sudo pacman -Rns "$@"; }

# Update the whole system
update() { sudo pacman -Syu; }

upackage() { sudo pacman -Sy "$@"; }

# Search for a package
search() { pacman -Ss "$@"; }

# Show info about a package
info() { pacman -Si "$@"; }

# List explicitly installed packages
installed() { pacman -Qe "$@"; }

# Find which package owns a file
owns() { pacman -Qo "$@"; }

# Clean package cache (keep last 2 versions)
clean() { sudo paccache -r; }


# ── File & Directory Shortcuts ──────────────────────────────

# Go up N directories (default 1)
up() {
    local n="${1:-1}"
    local path=""
    for ((i=0; i<n; i++)); do path="../$path"; done
    cd "$path" || return
}

# Create a directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" || return; }

# Quick find file by name
ff() { find . -iname "*$1*" 2>/dev/null; }

# Quick find file by content
fgrep() { grep -rn "$1" . 2>/dev/null; }

# Show directory size summary
dsize() { du -sh "${1:-.}"; }

# List all files sorted by size
lsize() { du -sh "${1:-.}"/* 2>/dev/null | sort -h; }


# ── Web Search from Terminal ────────────────────────────────

# Search Google in default browser
google() { xdg-open "https://www.google.com/search?q=$(echo "$*" | sed 's/ /+/g')"; }

# Search DuckDuckGo in default browser
duck() { xdg-open "https://duckduckgo.com/?q=$(echo "$*" | sed 's/ /+/g')"; }

# Search the Arch Wiki
archwiki() { xdg-open "https://wiki.archlinux.org/index.php?search=$(echo "$*" | sed 's/ /+/g')"; }

# Search the AUR
aursearch() { xdg-open "https://aur.archlinux.org/packages/?K=$(echo "$*" | sed 's/ /+/g')"; }

# Fetch a quick answer from wttr.in (weather)
weather() { curl -s "wttr.in/${1:-$(curl -s ifconfig.me/city)}?format=3"; }

# Get your public IP
myip() { curl -s ifconfig.me; echo; }

# Check if a site is up
isup() { curl -s --head --request GET "$1" | grep "200 OK" && echo "$1 is UP" || echo "$1 seems DOWN"; }


# ── System Info & Monitoring ────────────────────────────────

# Quick system overview
sysinfo() {
    echo "── CPU ──────────────────────────────"
    grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs
    echo "── Memory ───────────────────────────"
    free -h | awk 'NR==2{printf "Used: %s / Total: %s\n", $3, $2}'
    echo "── Disk ─────────────────────────────"
    df -h / | awk 'NR==2{printf "Used: %s / Total: %s (%s)\n", $3, $2, $5}'
    echo "── Uptime ───────────────────────────"
    uptime -p
}


# Show open ports
ports() { ss -tulnp; }

# Show journal errors from current boot
errors() { sudo journalctl -b --priority=err; }

# Follow the system journal live
log() { sudo journalctl -f; }


# ── systemd Service Shortcuts ───────────────────────────────

# Shorter aliases for common systemctl actions
sstart()   { sudo systemctl start "$1"; }
sstop()    { sudo systemctl stop "$1"; }
srestart() { sudo systemctl restart "$1"; }
sstatus()  { sudo systemctl status "$1"; }
senable()  { sudo systemctl enable --now "$1"; }
sdisable() { sudo systemctl disable --now "$1"; }


# ── Git Shortcuts ───────────────────────────────────────────

alias gs="git status"
alias ga="git add -A"
alias gc="git commit -m"
alias gp="git push"
alias gl="git log --oneline --graph --decorate -10"
alias gd="git diff"
repoc() {
  if [[ -z "$1" ]]; then
    echo "Usage: repoc <repo-name> [--public|--private]"
    return 1
  fi
  gh repo create "$1" "${2:---private}"
}
# Quick commit + push: gcp "your message"
gcp() { git branch -m main && git add -A && git commit -m "$*" && git push -u origin main; }

gremote() {
  if [[ -z "$1" ]]; then
    echo "Usage: gremote <github-url>"
    return 1
  fi
  git remote add origin "$1" && echo "Remote added: $1"
}
gupstream() {
  if [[ -z "$1" ]]; then
    echo "Usage: gupstream <github-url>"
    return 1
  fi
  git remote add upstream "$1" && echo "Upstream added: $1"
}

gpupmain() {
  git push --set-upstream origin main --force && echo "Force Pushed main to upstream."
}


# ── Misc Helpers ────────────────────────────────────────────

# Reload bashrc without restarting
reload() { source ~/.bashrc && echo "bashrc reloaded."; }

# Show command history filtered by keyword
hist() { history | grep "$1"; }

# Extract any archive format
extract() {
    case "$1" in
        *.tar.gz|*.tgz)  tar -xzf "$1"  ;;
        *.tar.bz2|*.tbz) tar -xjf "$1"  ;;
        *.tar.xz)        tar -xJf "$1"  ;;
        *.tar)           tar -xf  "$1"  ;;
        *.zip)           unzip    "$1"  ;;
        *.7z)            7z x     "$1"  ;;
        *.rar)           unrar x  "$1"  ;;
        *.gz)            gunzip   "$1"  ;;
        *.bz2)           bunzip2  "$1"  ;;
        *.xz)            unxz     "$1"  ;;
        *) echo "Unknown format: $1"    ;;
    esac
}

# Create a quick dated backup of a file
backup() { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"; }

# Show a cheat sheet of these commands
cmds() {
    echo ""
    echo "  ── Packages ──────────────────────────────────────────"
    echo "  install <pkg>       Install a package"
    echo "  remove  <pkg>       Remove package + unused deps"
    echo "  update              Full system update"
    echo "  search  <term>      Search package repos"
    echo "  info    <pkg>       Package details"
    echo "  installed           List explicitly installed"
    echo "  owns    <file>      Which package owns this file"
    echo "  clean               Clear old package cache"
    echo ""
    echo "  ── Files ─────────────────────────────────────────────"
    echo "  up [n]              Go up N directories"
    echo "  mkcd <dir>          Create dir and cd into it"
    echo "  ff <name>           Find file by name"
    echo "  fgrep <text>        Find file by content"
    echo "  dsize [dir]         Directory size"
    echo "  lsize [dir]         List sizes of all items"
    echo "  extract <archive>   Extract any archive"
    echo "  backup <file>       Dated backup of a file"
    echo ""
    echo "  ── Search / Web ──────────────────────────────────────"
    echo "  google <query>      Google in browser"
    echo "  duck <query>        DuckDuckGo in browser"
    echo "  archwiki <query>    Search Arch Wiki"
    echo "  aursearch <query>   Search AUR"
    echo "  weather [city]      Current weather"
    echo "  myip                Your public IP"
    echo "  isup <url>          Check if a site is reachable"
    echo ""
    echo "  ── System ────────────────────────────────────────────"
    echo "  sysinfo             CPU / RAM / Disk / Uptime"
    echo "  topcpu [n]          Top N processes by CPU"
    echo "  topmem [n]          Top N processes by RAM"
    echo "  ports               Show open ports"
    echo "  errors              Journal errors this boot"
    echo "  log                 Follow journal live"
    echo ""
    echo "  ── Services ──────────────────────────────────────────"
    echo "  sstart/sstop/srestart/sstatus/senable/sdisable <svc>"
    echo ""
    echo "  ── Git ───────────────────────────────────────────────"
    echo "  gs / ga / gc / gp / gl / gd"
    echo "  gcp <message>       Add + commit + push"
    echo ""
    echo "  ── Misc ──────────────────────────────────────────────"
    echo "  reload              Reload ~/.bashrc"
    echo "  hist <term>         Search command history"
    echo "  cmds                Show this cheat sheet"
    echo ""
}
