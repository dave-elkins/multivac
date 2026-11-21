#!/usr/bin/env bash
# multivac — personal agent knowledge core
#
# Install:   ./install.sh                        (clone + link + config; safe to re-run)
# Update:    ./install.sh                        (pulls latest, re-runs idempotently)
# Fresh box: ./install.sh --bootstrap            (also installs the toolchain; sudo)
#            ./install.sh --bootstrap --dry-run  (preview only, installs nothing)
# Doctor:    ./install.sh --doctor
# Uninstall: ./install.sh --uninstall             (removes links and config entry)
#            ./install.sh --uninstall --purge     (also deletes the clone)
#
# What install does:
#   1. Clones (or updates) the repo to ~/.local/share/multivac
#   2. Symlinks its skills/ into ~/.agents/skills/multivac   (open-standard location;
#      OpenCode V2 discovers global skills here automatically)
#   3. Adds the skills path to ~/.config/opencode/opencode.json (backup first)
#
set -euo pipefail

MULTIVAC_HOME="${MULTIVAC_HOME:-$HOME/.local/share/multivac}"
MULTIVAC_REPO="${MULTIVAC_REPO:-https://github.com/dave-elkins/multivac.git}"
AGENTS_SKILLS_DIR="$HOME/.agents/skills"
SKILLS_LINK="$AGENTS_SKILLS_DIR/multivac"
OPENCODE_DIR="$HOME/.config/opencode"
OPENCODE_CONFIG="$OPENCODE_DIR/opencode.json"

log()   { printf '  \033[1;32m==>\033[0m %s\n' "$*"; }
warn()  { printf '  \033[1;33m->>\033[0m %s\n' "$*"; }
fail()  { printf '  \033[1;31m!!\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

run_step() {
    # Print the command in dry-run mode; run it otherwise.
    if [ "${DRY_RUN:-0}" = "1" ]; then
        printf '  \033[1;34mdry\033[0m %s\n' "$*"
    else
        "$@"
    fi
}

link_ubuntu_alias() {
    # $1 = wanted name, $2 = Ubuntu binary name (fd/fdfind, bat/batcat).
    have "$1" && return 0
    command -v "$2" >/dev/null 2>&1 || return 0
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v "$2")" "$HOME/.local/bin/$1"
    log "Linked $HOME/.local/bin/$1 -> $(command -v "$2")"
}

check_deps() {
    command -v git >/dev/null 2>&1 || fail "git is required. Install it first."
    command -v jq >/dev/null 2>&1 || fail "jq is required. Install it first (e.g. 'sudo apt install jq' or 'brew install jq')."
    if ! command -v python3 >/dev/null 2>&1; then
        warn "python3 not found. The ste-writing checker script will not run until you install it."
    fi
}

clone_or_update() {
    if [ -d "$MULTIVAC_HOME/.git" ]; then
        if git -C "$MULTIVAC_HOME" remote get-url origin >/dev/null 2>&1 \
           && git -C "$MULTIVAC_HOME" rev-parse HEAD >/dev/null 2>&1; then
            log "Updating existing clone at $MULTIVAC_HOME"
            if ! git -C "$MULTIVAC_HOME" pull --ff-only; then
                warn "git pull failed. Continuing with the current checkout."
            fi
        else
            log "Found existing checkout at $MULTIVAC_HOME (no remote or no commits). Skipped update."
        fi
    elif [ -e "$MULTIVAC_HOME" ]; then
        fail "$MULTIVAC_HOME exists but is not a git clone. Move it aside or set MULTIVAC_HOME."
    else
        log "Cloning multivac to $MULTIVAC_HOME"
        git clone --quiet "$MULTIVAC_REPO" "$MULTIVAC_HOME"
    fi
}

link_skills() {
    mkdir -p "$AGENTS_SKILLS_DIR"
    if [ -L "$SKILLS_LINK" ] && [ "$(readlink "$SKILLS_LINK")" = "$MULTIVAC_HOME/skills" ]; then
        log "Skills symlink already in place"
    else
        if [ -e "$SKILLS_LINK" ] && [ ! -L "$SKILLS_LINK" ]; then
            fail "$SKILLS_LINK exists and is not a symlink. Remove it or inspect it first."
        fi
        ln -sfn "$MULTIVAC_HOME/skills" "$SKILLS_LINK"
        log "Linked $SKILLS_LINK -> $MULTIVAC_HOME/skills"
    fi
}

merge_opencode_config() {
    if [ -f "$OPENCODE_DIR/opencode.jsonc" ] && [ ! -f "$OPENCODE_CONFIG" ]; then
        warn "Found opencode.jsonc. This installer only edits opencode.json."
        warn "Add this to your jsonc manually: \"skills\": [\"$SKILLS_LINK\"]"
        return 0
    fi
    mkdir -p "$OPENCODE_DIR"
    if [ ! -f "$OPENCODE_CONFIG" ]; then
        cat > "$OPENCODE_CONFIG" <<'JSON'
{
  "$schema": "https://opencode.ai/config.json"
}
JSON
    fi
    if jq -e --arg p "$SKILLS_LINK" '(.skills // []) | index($p)' "$OPENCODE_CONFIG" >/dev/null 2>&1; then
        log "opencode.json already lists the multivac skills source"
    else
        local backup
        backup="$OPENCODE_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
        cp "$OPENCODE_CONFIG" "$backup"
        local tmp
        tmp=$(mktemp)
        jq --arg p "$SKILLS_LINK" \
            '.skills = ((.skills // []) + [$p] | unique)' \
            "$OPENCODE_CONFIG" > "$tmp"
        mv "$tmp" "$OPENCODE_CONFIG"
        log "Added skills entry to opencode.json (backup: $backup)"
    fi
}

do_install() {
    check_deps
    clone_or_update
    link_skills
    merge_opencode_config
    echo
    log "Installed. Skills discovered by ID:"
    find "$MULTIVAC_HOME/skills" -name SKILL.md -printf '%h\n' 2>/dev/null \
        | while read -r d; do printf '    %s\n' "$(basename "$d")"; done | sort
    echo
    log "OpenCode reloads config automatically. Start a new session, or run /reload."
}

do_uninstall() {
    local purge=0
    [ "${1:-}" = "--purge" ] && purge=1
    if [ -L "$SKILLS_LINK" ]; then
        rm "$SKILLS_LINK"
        log "Removed $SKILLS_LINK"
    else
        warn "No symlink at $SKILLS_LINK"
    fi
    if [ -f "$OPENCODE_CONFIG" ] && jq -e '(.skills // []) | length > 0' "$OPENCODE_CONFIG" >/dev/null 2>&1; then
        local backup tmp
        backup="$OPENCODE_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
        cp "$OPENCODE_CONFIG" "$backup"
        tmp=$(mktemp)
        jq --arg p "$SKILLS_LINK" \
            '.skills = ((.skills // []) | map(select(. != $p)))' \
            "$OPENCODE_CONFIG" > "$tmp"
        mv "$tmp" "$OPENCODE_CONFIG"
        log "Removed skills entry from opencode.json (backup: $backup)"
    fi
    if [ "$purge" = "1" ] && [ -d "$MULTIVAC_HOME/.git" ]; then
        rm -rf "$MULTIVAC_HOME"
        log "Deleted clone at $MULTIVAC_HOME"
    else
        warn "Clone kept at $MULTIVAC_HOME (use --purge to delete)"
    fi
}

do_bootstrap() {
    DRY_RUN=0
    [ "${1:-}" = "--dry-run" ] && DRY_RUN=1

    if [ "$DRY_RUN" = "0" ]; then
        command -v apt-get >/dev/null 2>&1 \
            || fail "--bootstrap targets apt-based Linux. No apt-get found."
        command -v sudo >/dev/null 2>&1 \
            || fail "--bootstrap needs sudo for system packages."
    fi

    echo
    log "Tier 1: core CLI tools (apt)"
    # binary|apt-package pairs. Install only what is missing.
    local pairs=(
        "git|git" "jq|jq" "rg|ripgrep" "fd|fd-find" "fzf|fzf" "bat|bat"
        "shellcheck|shellcheck" "shfmt|shfmt" "tmux|tmux" "direnv|direnv"
        "watchexec|watchexec"
    )
    local missing_pkgs=()
    local pair bin pkg
    for pair in "${pairs[@]}"; do
        bin="${pair%%|*}"
        pkg="${pair##*|}"
        if have "$bin"; then
            log "  $bin: present"
        else
            log "  $bin: missing (apt: $pkg)"
            missing_pkgs+=("$pkg")
        fi
    done
    if [ "${#missing_pkgs[@]}" -gt 0 ]; then
        log "Installing: ${missing_pkgs[*]}"
        run_step sudo apt-get update -y \
            || warn "apt-get update failed; trying install anyway"
        for pkg in "${missing_pkgs[@]}"; do
            # One package at a time. One unavailable package must not
            # block the rest.
            run_step sudo apt-get install -y "$pkg" \
                || warn "could not install $pkg via apt. Install it from its release page."
        done
        if [ "$DRY_RUN" = "0" ]; then
            # Ubuntu ships 'fdfind' and 'batcat'. Link the expected names.
            link_ubuntu_alias fd fdfind
            link_ubuntu_alias bat batcat
        fi
    else
        log "All core CLI tools present"
    fi

    echo
    log "Tier 2: snaps (gh, vale)"
    if have snap; then
        if have gh; then log "  gh: present"; else
            log "  gh: installing via snap (sudo)"
            run_step sudo snap install gh --classic \
                || warn "could not install gh via snap"
        fi
        if have vale; then log "  vale: present"; else
            log "  vale: installing via snap (sudo)"
            run_step sudo snap install vale \
                || warn "could not install vale via snap"
        fi
    else
        warn "snap not found. Install gh and vale manually."
    fi

    echo
    log "Tier 3: uv and Python tools"
    if have uv; then log "  uv: present"; else
        log "  uv: installing via the official installer"
        run_step sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
    fi
    local uv_bin
    uv_bin="$(command -v uv || true)"
    if [ -z "$uv_bin" ] && [ -x "$HOME/.local/bin/uv" ]; then
        uv_bin="$HOME/.local/bin/uv"
    fi
    if [ -n "$uv_bin" ]; then
        local t
        for t in ruff ty mypy; do
            if have "$t"; then
                log "  $t: present"
            else
                log "  $t: uv tool install"
                run_step "$uv_bin" tool install "$t"
            fi
        done
    else
        warn "uv not found after the install step. Re-run --bootstrap in a new shell."
    fi

    echo
    log "Tier 4: bun and writing tools"
    if have bun; then log "  bun: present"; else
        log "  bun: installing via the official installer"
        run_step sh -c 'curl -fsSL https://bun.sh/install | bash'
    fi
    local bun_bin
    bun_bin="$(command -v bun || true)"
    if [ -z "$bun_bin" ] && [ -x "$HOME/.bun/bin/bun" ]; then
        bun_bin="$HOME/.bun/bin/bun"
    fi
    if [ -n "$bun_bin" ]; then
        local b
        for b in cspell markdownlint-cli2; do
            if have "$b"; then
                log "  $b: present"
            else
                log "  $b: bun install -g"
                run_step "$bun_bin" install -g "$b"
            fi
        done
    else
        warn "bun not found after the install step. Re-run --bootstrap in a new shell."
    fi

    echo
    log "Tier 5: beads (bd)"
    if have bd; then
        log "  bd: present"
    else
        log "  bd: installing via the official installer (steveyegge/beads)"
        run_step sh -c 'curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash'
    fi

    echo
    if [ "$DRY_RUN" = "1" ]; then
        log "Dry run complete. Nothing was installed."
    else
        log "Bootstrap complete. Open a new shell so PATH picks up ~/.local/bin and ~/.bun/bin."
        log "Then run ./install.sh --doctor to verify."
    fi
}

do_doctor() {
    local ok=0
    printf 'multivac doctor\n\n'
    if command -v git >/dev/null 2>&1; then log "git: ok"; else warn "git: MISSING"; ok=1; fi
    if command -v jq >/dev/null 2>&1; then log "jq: ok"; else warn "jq: MISSING"; ok=1; fi
    if command -v python3 >/dev/null 2>&1; then log "python3: ok"; else warn "python3: missing (ste-writing checker disabled)"; fi
    if [ -d "$MULTIVAC_HOME/.git" ]; then
        if git -C "$MULTIVAC_HOME" remote get-url origin >/dev/null 2>&1; then
            log "clone: $MULTIVAC_HOME ($(git -C "$MULTIVAC_HOME" remote get-url origin))"
        else
            warn "clone: $MULTIVAC_HOME (no origin remote)"
        fi
        if git -C "$MULTIVAC_HOME" rev-parse HEAD >/dev/null 2>&1; then
            log "clone revision: $(git -C "$MULTIVAC_HOME" rev-parse --short HEAD)"
        else
            warn "clone revision: no commits yet"
        fi
    else
        warn "clone: MISSING at $MULTIVAC_HOME"
        ok=1
    fi
    if [ -L "$SKILLS_LINK" ] && [ -d "$SKILLS_LINK" ]; then
        log "skills link: $SKILLS_LINK -> $(readlink "$SKILLS_LINK")"
    else
        warn "skills link: MISSING at $SKILLS_LINK"
        ok=1
    fi
    if [ -f "$OPENCODE_CONFIG" ]; then
        if jq -e --arg p "$SKILLS_LINK" '(.skills // []) | index($p)' "$OPENCODE_CONFIG" >/dev/null 2>&1; then
            log "opencode config: skills entry present"
        else
            warn "opencode config: skills entry not found in $OPENCODE_CONFIG"
            ok=1
        fi
    else
        warn "opencode config: $OPENCODE_CONFIG not found"
        ok=1
    fi
    printf '\nSkills that will be discovered by ID:\n'
    find "$MULTIVAC_HOME/skills" -name SKILL.md -printf '%h\n' 2>/dev/null \
        | while read -r d; do printf '    %s\n' "$(basename "$d")"; done | sort
    printf '\nBootstrap tools (informational):\n'
    local tools=(
        git jq rg fd fzf bat shellcheck shfmt tmux direnv watchexec
        gh snap uv ruff ty mypy bun cspell markdownlint-cli2 vale bd
    )
    local t
    for t in "${tools[@]}"; do
        if have "$t"; then printf '    %-18s ok\n' "$t"; else printf '    %-18s -\n' "$t"; fi
    done
    [ "$ok" = "0" ] && printf '\nAll systems nominal.\n' || printf '\nProblems found. Re-run ./install.sh or fix the warnings above.\n'
    exit "$ok"
}

case "${1:-install}" in
    install|"")   do_install ;;
    --doctor|-D)  do_doctor ;;
    --uninstall)  do_uninstall "${2:-}" ;;
    --bootstrap)  do_install; do_bootstrap "${2:-}" ;;
    --help|-h)
        sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
        ;;
    *) fail "Unknown option: $1 (try --help)" ;;
esac
