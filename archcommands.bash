#!/usr/bin/env bash
##############################################################
#  Cross-Distro — Custom Simplified Commands
#  Supports: Arch Linux, Debian/Ubuntu, Fedora
#  Add to your ~/.bashrc:  source ~/linux_commands.bash
#  or paste directly into ~/.bashrc
##############################################################


# ── Distro Detection ────────────────────────────────────────

_detect_distro() {
    if [[ -n "$LINUX_CMDS_DISTRO" ]]; then
        # Allow manual override: export LINUX_CMDS_DISTRO=arch|debian|fedora
        echo "$LINUX_CMDS_DISTRO"
        return
    fi
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        local id="${ID,,}"
        local id_like="${ID_LIKE,,}"
        if [[ "$id" == "arch" || "$id_like" == *arch* ]]; then
            echo "arch"
        elif [[ "$id" == "fedora" || "$id_like" == *fedora* || "$id_like" == *rhel* ]]; then
            echo "fedora"
        elif [[ "$id" == "debian" || "$id" == "ubuntu" || "$id_like" == *debian* ]]; then
            echo "debian"
        else
            echo "unknown"
        fi
    elif command -v pacman &>/dev/null; then
        echo "arch"
    elif command -v dnf &>/dev/null; then
        echo "fedora"
    elif command -v apt &>/dev/null; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Cache the detected distro once per shell
LINUX_CMDS_DETECTED_DISTRO="$(_detect_distro)"

_unsupported_distro() {
    echo "This command isn't supported on '$LINUX_CMDS_DETECTED_DISTRO'."
    echo "You can override detection with: export LINUX_CMDS_DISTRO=arch|debian|fedora"
    return 1
}


# ── Package Management ──────────────────────────────────────

install() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   sudo pacman -S "$@" ;;
        debian) sudo apt install "$@" ;;
        fedora) sudo dnf install "$@" ;;
        *) _unsupported_distro ;;
    esac
}

remove() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   sudo pacman -Rns "$@" ;;
        debian) sudo apt remove --autoremove "$@" ;;
        fedora) sudo dnf remove "$@" ;;
        *) _unsupported_distro ;;
    esac
}

update() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   sudo pacman -Syu ;;
        debian) sudo apt update && sudo apt upgrade ;;
        fedora) sudo dnf upgrade --refresh ;;
        *) _unsupported_distro ;;
    esac
}

upackage() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   sudo pacman -Sy "$@" ;;
        debian) sudo apt install "$@" ;;
        fedora) sudo dnf install "$@" ;;
        *) _unsupported_distro ;;
    esac
}

search() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   pacman -Ss "$@" ;;
        debian) apt search "$@" ;;
        fedora) dnf search "$@" ;;
        *) _unsupported_distro ;;
    esac
}

info() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   pacman -Si "$@" ;;
        debian) apt show "$@" ;;
        fedora) dnf info "$@" ;;
        *) _unsupported_distro ;;
    esac
}

# List explicitly/manually installed packages
installed() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   pacman -Qe "$@" ;;
        debian) apt-mark showmanual "$@" ;;
        fedora) dnf repoquery --userinstalled "$@" ;;
        *) _unsupported_distro ;;
    esac
}

# Find which package owns a file
owns() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   pacman -Qo "$@" ;;
        debian) dpkg -S "$@" ;;
        fedora) dnf provides "$@" ;;
        *) _unsupported_distro ;;
    esac
}

# Clean package cache / unused deps
clean() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   sudo paccache -r ;;
        debian) sudo apt autoremove && sudo apt clean ;;
        fedora) sudo dnf clean all && sudo dnf autoremove ;;
        *) _unsupported_distro ;;
    esac
}


# ── File & Directory Shortcuts (distro-independent) ─────────

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
# (named `findtext`, not `fgrep` — many distros predefine an `fgrep` alias,
#  e.g. `alias fgrep='fgrep --color=auto'` in /etc/bash.bashrc, and bash
#  expands that alias before parsing `fgrep() { ... }`, causing a
#  "syntax error near unexpected token `('" when sourced.)
findtext() { grep -rn "$1" . 2>/dev/null; }

# Show directory size summary
dsize() { du -sh "${1:-.}"; }

# List all files sorted by size
lsize() { du -sh "${1:-.}"/* 2>/dev/null | sort -h; }


# ── Web Search from Terminal (distro-independent) ───────────

# Search Google in default browser
google() { xdg-open "https://www.google.com/search?q=$(echo "$*" | sed 's/ /+/g')"; }

# Search DuckDuckGo in default browser
duck() { xdg-open "https://duckduckgo.com/?q=$(echo "$*" | sed 's/ /+/g')"; }

# Fetch a quick answer from wttr.in (weather)
weather() { curl -s "wttr.in/${1:-$(curl -s ifconfig.me/city)}?format=3"; }

# Get your public IP
myip() { curl -s ifconfig.me; echo; }

# Check if a site is up
isup() { curl -s --head --request GET "$1" | grep "200 OK" && echo "$1 is UP" || echo "$1 seems DOWN"; }

# Search distro-specific docs/wiki/AUR
docsearch() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   xdg-open "https://wiki.archlinux.org/index.php?search=$(echo "$*" | sed 's/ /+/g')" ;;
        debian) xdg-open "https://www.debian.org/search.html?words=$(echo "$*" | sed 's/ /+/g')" ;;
        fedora) xdg-open "https://docs.fedoraproject.org/en-US/search/?q=$(echo "$*" | sed 's/ /+/g')" ;;
        *) _unsupported_distro ;;
    esac
}

# Search the AUR (Arch) or COPR (Fedora); no-op elsewhere
aursearch() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        arch)   xdg-open "https://aur.archlinux.org/packages/?K=$(echo "$*" | sed 's/ /+/g')" ;;
        fedora) xdg-open "https://copr.fedorainfracloud.org/coprs/fulltext/?fulltext=$(echo "$*" | sed 's/ /+/g')" ;;
        *) _unsupported_distro ;;
    esac
}


# ── System Info & Monitoring (distro-independent) ───────────

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

# Firewall shortcuts — firewalld on Fedora, ufw on Debian/Ubuntu, unmanaged on Arch
fwstatus() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        fedora) sudo firewall-cmd --state && sudo firewall-cmd --list-all ;;
        debian) sudo ufw status verbose ;;
        arch)   echo "Arch has no default firewall manager. Check iptables/nftables/ufw if installed." ;;
        *) _unsupported_distro ;;
    esac
}
fwopen() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        fedora) sudo firewall-cmd --permanent --add-port="$1" && sudo firewall-cmd --reload ;;
        debian) sudo ufw allow "$1" ;;
        *) _unsupported_distro ;;
    esac
}
fwclose() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        fedora) sudo firewall-cmd --permanent --remove-port="$1" && sudo firewall-cmd --reload ;;
        debian) sudo ufw deny "$1" ;;
        *) _unsupported_distro ;;
    esac
}

# SELinux checks (Fedora); AppArmor checks (Debian/Ubuntu); n/a on Arch
sestatus_short() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        fedora) getenforce ;;
        debian) sudo aa-status 2>/dev/null || echo "AppArmor not installed/active." ;;
        *) _unsupported_distro ;;
    esac
}
seaudit() {
    case "$LINUX_CMDS_DETECTED_DISTRO" in
        fedora) sudo ausearch -m avc -ts recent ;;
        debian) sudo journalctl -k | grep -i apparmor ;;
        *) _unsupported_distro ;;
    esac
}


# ── systemd Service Shortcuts (distro-independent) ──────────

sstart()   { sudo systemctl start "$1"; }
sstop()    { sudo systemctl stop "$1"; }
srestart() { sudo systemctl restart "$1"; }
sstatus()  { sudo systemctl status "$1"; }
senable()  { sudo systemctl enable --now "$1"; }
sdisable() { sudo systemctl disable --now "$1"; }


# ── Git Shortcuts (distro-independent) ──────────────────────

alias gs="git status"
alias ga="git add ."
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


# ── Misc Helpers (distro-independent) ───────────────────────

reload() { source ~/.bashrc && echo "bashrc reloaded."; }

hist() { history | grep "$1"; }

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

backup() { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"; }

# Show which distro was detected
whichdistro() { echo "Detected distro family: $LINUX_CMDS_DETECTED_DISTRO"; }

# Show a cheat sheet of these commands
cmds() {
    echo ""
    echo "  Detected distro: $LINUX_CMDS_DETECTED_DISTRO"
    echo "  (override with: export LINUX_CMDS_DISTRO=arch|debian|fedora)"
    echo ""
    echo "  ── Packages ──────────────────────────────────────────"
    echo "  install <pkg>       Install a package"
    echo "  remove  <pkg>       Remove package + unused deps"
    echo "  update              Full system update"
    echo "  search  <term>      Search package repos"
    echo "  info    <pkg>       Package details"
    echo "  installed           List explicitly/manually installed"
    echo "  owns    <file>      Which package owns this file"
    echo "  clean               Clear cache / unused deps"
    echo ""
    echo "  ── Files ─────────────────────────────────────────────"
    echo "  up [n]              Go up N directories"
    echo "  mkcd <dir>          Create dir and cd into it"
    echo "  ff <name>           Find file by name"
    echo "  findtext <text>     Find file by content"
    echo "  dsize [dir]         Directory size"
    echo "  lsize [dir]         List sizes of all items"
    echo "  extract <archive>   Extract any archive"
    echo "  backup <file>       Dated backup of a file"
    echo ""
    echo "  ── Search / Web ──────────────────────────────────────"
    echo "  google <query>      Google in browser"
    echo "  duck <query>        DuckDuckGo in browser"
    echo "  docsearch <query>   Search distro docs/wiki"
    echo "  aursearch <query>   Search AUR (Arch) / COPR (Fedora)"
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
    echo "  fwstatus            Firewall status (firewalld/ufw)"
    echo "  fwopen <port/proto> Open a firewall port"
    echo "  fwclose <port/proto> Close a firewall port"
    echo "  sestatus_short      SELinux (Fedora) / AppArmor (Debian) status"
    echo "  seaudit             Recent SELinux/AppArmor denials"
    echo "  whichdistro         Show detected distro family"
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
