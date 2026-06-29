#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$SCRIPT_DIR/setup.conf"
SHORTCUTS_PLIST="$SCRIPT_DIR/macos/symbolichotkeys.plist"

# Silence Homebrew's auto-update / hint / cleanup chatter — pure noise, never wanted.
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_INSTALL_CLEANUP=1
VERBOSE=0

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { printf "${YELLOW}%s${NC}\n" "$1"; }
ok()    { printf "${GREEN}%s${NC}\n" "$1"; }
err()   { printf "${RED}%s${NC}\n" "$1"; }

# run_step <title> <cmd...> — verbose: show all output; minimum: a single spinner line.
# ponytail: --show-output keeps stderr so a sudo/password prompt isn't hidden behind the spinner.
run_step() {
  local title="$1"; shift
  if [ "$VERBOSE" = 1 ]; then info "$title"; "$@"
  else gum spin --show-output --spinner dot --title "$title" -- "$@"; fi
}

# first editor that actually exists — fresh mac may lack $EDITOR's target; vi always ships.
edit_conf() {
  local e
  for e in "${EDITOR:-}" nvim vim nano vi; do
    [ -n "$e" ] && command -v "$e" >/dev/null 2>&1 && { "$e" "$CONF"; return; }
  done
  err "No editor found — edit $CONF by hand."
}

ensure_clt() {
  xcode-select -p >/dev/null 2>&1 && return 0
  info "Installing Xcode Command Line Tools — accept the popup, then wait."
  xcode-select --install >/dev/null 2>&1 || true
  # ponytail: polls until present; ctrl-C to abort if you cancel the dialog.
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  ok "Command Line Tools installed."
}

ensure_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi
}

ensure_gum() {
  command -v gum >/dev/null 2>&1 || { info "Installing gum (TUI)..."; brew install gum; }
}

load_conf() {
  if [ ! -f "$CONF" ]; then
    info "No setup.conf yet — creating one from setup.conf.example."
    cp "$SCRIPT_DIR/setup.conf.example" "$CONF"
    gum confirm "Edit setup.conf now?" && edit_conf
  fi
  # shellcheck disable=SC1090
  source "$CONF"
  declare -p BREW_TERMINALS >/dev/null 2>&1 || BREW_TERMINALS=()
  declare -p MAS_APPS >/dev/null 2>&1 || MAS_APPS=()
}

# save_repo <name> <new_url> — persist a clone URL back into CONFIG_REPOS, preserving the path.
# ponytail: sed on the name-prefixed line; breaks only if a git url contains '~' or '&' (it won't).
save_repo() {
  sed -i '' "s~\"${1}|[^|]*|~\"${1}|${2}|~" "$CONF"
}
save_private() {
  sed -i '' "s~^PRIVATE_REPO=.*~PRIVATE_REPO=\"${1}\"~" "$CONF"
}

# brew_get <flag> <pkg...> — install each pkg unless already present. <flag> is "" or "--cask".
brew_get() {
  local flag="$1"; shift
  local todo=()
  for p in "$@"; do
    if brew list $flag "$p" >/dev/null 2>&1; then ok "$p already installed — skipping"; else todo+=("$p"); fi
  done
  [ "${#todo[@]}" -eq 0 ] && return 0
  gum confirm "Install: ${todo[*]} ?" || { info "skipped"; return 0; }
  for p in "${todo[@]}"; do
    run_step "Installing $p" brew install $flag "$p" || err "failed: $p"
  done
}

do_zsh() {
  gum confirm "Install Oh My Zsh + Powerlevel10k + plugins?" || { info "skipped"; return 0; }
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Oh My Zsh already installed"
  else
    run_step "Installing Oh My Zsh" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || err "oh-my-zsh install failed"
  fi
  [ -d "$custom/themes/powerlevel10k" ] || run_step "Powerlevel10k" git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k" || err "p10k clone failed"
  [ -d "$custom/plugins/zsh-autosuggestions" ]          || run_step "zsh-autosuggestions" git clone https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions" || err "clone failed"
  [ -d "$custom/plugins/zsh-history-substring-search" ] || run_step "zsh-history-substring-search" git clone https://github.com/zsh-users/zsh-history-substring-search "$custom/plugins/zsh-history-substring-search" || err "clone failed"
  [ -d "$custom/plugins/zsh-syntax-highlighting" ]      || run_step "zsh-syntax-highlighting" git clone https://github.com/zsh-users/zsh-syntax-highlighting "$custom/plugins/zsh-syntax-highlighting" || err "clone failed"
  if [ -f "$HOME/.zshrc" ]; then
    sed -i '' 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
    sed -i '' 's|^plugins=.*|plugins=(git jump zsh-autosuggestions sublime zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)|' "$HOME/.zshrc"
  fi
  ok "Shell configured — restart your terminal to see it."
}

do_apps() {
  local picks
  if [ "${#BREW_FORMULAE[@]}" -gt 0 ]; then
    picks=$(printf '%s\n' "${BREW_FORMULAE[@]}" | gum choose --no-limit --header="Formulae (CLI) — space to toggle, enter to confirm") || return 0
    [ -n "$picks" ] && brew_get "" $picks
  fi
  if [ "${#BREW_TERMINALS[@]}" -gt 0 ]; then
    picks=$(printf '%s\n' "${BREW_TERMINALS[@]}" | gum choose --no-limit --header="Terminals") || return 0
    [ -n "$picks" ] && brew_get "--cask" $picks
  fi
  if [ "${#BREW_CASKS[@]}" -gt 0 ]; then
    picks=$(printf '%s\n' "${BREW_CASKS[@]}" | gum choose --no-limit --header="Casks (apps)") || return 0
    [ -n "$picks" ] && brew_get "--cask" $picks
  fi
  if [ "${#MAS_APPS[@]}" -gt 0 ]; then
    command -v mas >/dev/null 2>&1 || { info "Installing mas (Mac App Store CLI)..."; brew install mas; }
    local names=(); for a in "${MAS_APPS[@]}"; do names+=("${a#*|}"); done
    picks=$(printf '%s\n' "${names[@]}" | gum choose --no-limit --header="Mac App Store (sign into App Store first)") || return 0
    while IFS= read -r name; do
      [ -z "$name" ] && continue
      for a in "${MAS_APPS[@]}"; do
        [ "${a#*|}" = "$name" ] && { info "mas install $name (${a%%|*})"; mas install "${a%%|*}" || err "failed: $name — App Store signed in?"; }
      done
    done <<< "$picks"
  fi
  ok "Apps done."
}

do_configs() {
  local entry name url path
  for entry in "${CONFIG_REPOS[@]}"; do
    name="${entry%%|*}"; path="${entry##*|}"; url="${entry#*|}"; url="${url%%|*}"
    if [ -z "$url" ]; then
      url=$(gum input --placeholder "git url for '$name' (blank to skip)") || continue
      [ -z "$url" ] && { info "skip $name"; continue; }
      save_repo "$name" "$url"
    fi
    if [ -d "$path" ]; then
      gum confirm "$path exists — back it up and re-clone $name?" || { info "skip $name"; continue; }
      mv "$path" "$path.bak.$(date +%s)"
    fi
    mkdir -p "$(dirname "$path")"
    info "cloning $name -> $path"
    git clone "$url" "$path" && ok "$name cloned" || err "clone failed: $name"
  done
}

do_private() {
  [ -z "$PRIVATE_REPO" ] && { PRIVATE_REPO=$(gum input --placeholder "private repo git url") || return 0; [ -n "$PRIVATE_REPO" ] && save_private "$PRIVATE_REPO"; }
  [ -z "$PRIVATE_REPO" ] && return 0
  if [ -d "$PRIVATE_REPO_PATH" ]; then
    info "pulling $PRIVATE_REPO_PATH"; git -C "$PRIVATE_REPO_PATH" pull --ff-only || err "pull failed"
  else
    info "cloning private repo -> $PRIVATE_REPO_PATH"; git clone "$PRIVATE_REPO" "$PRIVATE_REPO_PATH" && ok "cloned" || err "clone failed"
  fi
}

do_macos() {
  local entry domain key type value
  for entry in "${MACOS_DEFAULTS[@]}"; do
    read -r domain key type value <<< "$entry"
    info "defaults write $domain $key -$type $value"
    defaults write "$domain" "$key" "-$type" "$value" || err "failed: $domain $key"
  done
  killall Dock Finder SystemUIServer >/dev/null 2>&1 || true
  ok "macOS defaults applied."
}

do_shortcuts() {
  mkdir -p "$(dirname "$SHORTCUTS_PLIST")"
  case "$(gum choose 'Capture current keyboard shortcuts' 'Restore shortcuts from repo')" in
    Capture*)
      defaults export com.apple.symbolichotkeys "$SHORTCUTS_PLIST" && ok "saved -> $SHORTCUTS_PLIST (commit it)"
      ;;
    Restore*)
      [ -f "$SHORTCUTS_PLIST" ] || { err "no $SHORTCUTS_PLIST to restore"; return 0; }
      defaults import com.apple.symbolichotkeys "$SHORTCUTS_PLIST"
      killall cfprefsd >/dev/null 2>&1 || true
      ok "restored — log out/in for shortcuts to take effect"
      ;;
  esac
}

intro() {
  clear
  gum style --border double --padding "1 2" --margin "1 0" --border-foreground 212 \
    "macOS setup" \
    "" \
    "It walks each step in order — you pick what to install at each one." \
    "No sudo/root is used by this script." \
    "Read the source before trusting it: setup.sh + setup.conf" \
    "" \
    "Manifest: ${#BREW_FORMULAE[@]} CLI · $(( ${#BREW_TERMINALS[@]} + ${#BREW_CASKS[@]} )) apps · ${#MACOS_DEFAULTS[@]} macOS tweaks"
  gum confirm "Understood — continue?" || { ok "Bye."; exit 0; }
  gum choose --header="Output level" "Minimum" "Verbose" | grep -q Verbose && VERBOSE=1 || true
}

hdr() { gum style --bold --foreground 212 --margin "1 0" "▶ $1"; }

# chronological wizard — each step runs in order, you select within it, then it moves on.
run() {
  hdr "Shell (Oh My Zsh)";  do_zsh
  hdr "Apps";               do_apps
  hdr "Config repos";       do_configs
  hdr "Private repo";       do_private
  hdr "macOS defaults";     gum confirm "Apply macOS defaults from the manifest?" && do_macos || info "skipped"
  hdr "Keyboard shortcuts"; gum confirm "Set up keyboard shortcuts now?" && do_shortcuts || info "skipped"
  ok "All done — close and reopen your terminal."
}

selftest() {
  local tmp; tmp="$(mktemp)"; CONF="$tmp"
  printf 'CONFIG_REPOS=(\n  "nvim||$HOME/.config/nvim"\n)\nPRIVATE_REPO=""\n' > "$tmp"
  save_repo nvim "git@github.com:me/nvim.git"
  save_private "git@github.com:me/dots.git"
  grep -q '"nvim|git@github.com:me/nvim.git|$HOME/.config/nvim"' "$tmp" || { err "save_repo failed"; cat "$tmp"; exit 1; }
  grep -q 'PRIVATE_REPO="git@github.com:me/dots.git"' "$tmp" || { err "save_private failed"; cat "$tmp"; exit 1; }
  rm -f "$tmp"; ok "selftest passed"
}

main() {
  [ "${1:-}" = "--selftest" ] && { selftest; exit 0; }
  ensure_clt
  ensure_brew
  ensure_gum
  load_conf
  intro
  run
}

main "$@"
