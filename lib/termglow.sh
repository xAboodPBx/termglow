#!/usr/bin/env bash
# TermGlow — portable shell prompt engine.
# shellcheck shell=bash

TERMGlow_VERSION="1.0.0"
TERMGlow_ROOT="${TERMGlow_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TERMGlow_CONFIG_DIR="${TERMGlow_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/termglow}"
TERMGlow_THEME_FILE="${TERMGlow_THEME_FILE:-$TERMGlow_CONFIG_DIR/theme}"
TERMGlow_DEFAULT_THEME="aurora"
TERMGlow_MARKER_BEGIN="# >>> termglow initialize >>>"
TERMGlow_MARKER_END="# <<< termglow initialize <<<"

termglow_theme_dir() {
  printf '%s/themes\n' "$TERMGlow_ROOT"
}

termglow_list_themes() {
  local file name
  for file in "$(termglow_theme_dir)"/*.theme; do
    [ -f "$file" ] || continue
    name="$(basename "$file" .theme)"
    # shellcheck disable=SC1090
    unset TG_NAME TG_DESCRIPTION TG_SYMBOL TG_PRIMARY TG_SECONDARY TG_ACCENT TG_ERROR TG_MUTED TG_RESET
    source "$file"
    printf '%-12s %s\n' "$name" "${TG_DESCRIPTION:-No description}"
  done
}

termglow_theme_exists() {
  [ -f "$(termglow_theme_dir)/$1.theme" ]
}

termglow_current_theme() {
  if [ -f "$TERMGlow_THEME_FILE" ]; then
    local theme
    theme="$(head -n 1 "$TERMGlow_THEME_FILE" 2>/dev/null)"
    if termglow_theme_exists "$theme"; then
      printf '%s\n' "$theme"
      return 0
    fi
  fi
  printf '%s\n' "$TERMGlow_DEFAULT_THEME"
}

termglow_set_theme() {
  local theme="$1"
  if ! termglow_theme_exists "$theme"; then
    printf 'TermGlow: unknown theme "%s". Use "termglow list" to see available themes.\n' "$theme" >&2
    return 1
  fi
  mkdir -p "$TERMGlow_CONFIG_DIR"
  printf '%s\n' "$theme" > "$TERMGlow_THEME_FILE"
  termglow_apply_theme "$theme"
  printf 'Applied theme: %s\n' "$theme"
}

termglow_apply_theme() {
  local theme="${1:-$(termglow_current_theme)}"
  local theme_file="$(termglow_theme_dir)/$theme.theme"
  if ! [ -f "$theme_file" ]; then
    theme="$TERMGlow_DEFAULT_THEME"
    theme_file="$(termglow_theme_dir)/$theme.theme"
  fi
  # shellcheck disable=SC1090
  source "$theme_file"
  export TERMGlow_ACTIVE_THEME="$theme"

  if [ -n "${ZSH_VERSION:-}" ]; then
    setopt PROMPT_SUBST 2>/dev/null || true
    precmd_functions=(${precmd_functions:#__termglow_prompt})
    precmd_functions+=(__termglow_prompt)
  else
    case ";${PROMPT_COMMAND:-};" in
      *";__termglow_prompt;"*|";__termglow_prompt"*) ;;
      *) PROMPT_COMMAND="__termglow_prompt${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
    esac
  fi
}

__termglow_git_branch() {
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local branch
  branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null || command git rev-parse --short HEAD 2>/dev/null)"
  [ -n "$branch" ] && printf ' %s%s%s' "${TG_MUTED:-}" "${TG_GIT_PREFIX:-on }$branch" "${TG_RESET:-}"
}

__termglow_prompt() {
  local last_status=$?
  local status_segment=""
  local host_segment="\u@\h"
  local branch_segment
  branch_segment='$(__termglow_git_branch)'

  if [ "$last_status" -ne 0 ]; then
    status_segment=" ${TG_ERROR:-}[✘ $last_status]${TG_RESET:-}"
  fi

  case "${TG_LAYOUT:-single}" in
    multiline)
      PS1="${TG_MUTED:-}[${TG_PRIMARY:-}\t${TG_MUTED:-}] ${TG_ACCENT:-}${TG_SYMBOL:-❯}${TG_RESET:-} ${TG_PRIMARY:-}${host_segment}${TG_RESET:-} ${TG_SECONDARY:-\w}${TG_RESET:-}${branch_segment}${status_segment}\n${TG_PROMPT_CHAR:-❯} "
      ;;
    compact)
      PS1="${TG_PRIMARY:-}${TG_SYMBOL:-❯}${TG_RESET:-} ${TG_SECONDARY:-\W}${TG_RESET:-}${branch_segment}${status_segment} ${TG_PROMPT_CHAR:-❯} "
      ;;
    *)
      PS1="${TG_PRIMARY:-}${TG_SYMBOL:-❯}${TG_RESET:-} ${TG_PRIMARY:-}${host_segment}${TG_RESET:-}:${TG_SECONDARY:-\w}${TG_RESET:-}${branch_segment}${status_segment} ${TG_PROMPT_CHAR:-❯} "
      ;;
  esac
}

termglow_preview() {
  local theme="${1:-$(termglow_current_theme)}"
  if ! termglow_theme_exists "$theme"; then
    printf 'TermGlow: unknown theme "%s".\n' "$theme" >&2
    return 1
  fi
  termglow_apply_theme "$theme"
  __termglow_prompt
  printf '\n%s\n' "${TG_ACCENT:-}Theme: $theme${TG_RESET:-}"
  printf '  %s\n' "$PS1"
  printf '  %s\n' "${TG_PRIMARY:-}Primary${TG_RESET:-}  ${TG_SECONDARY:-}Secondary${TG_RESET:-}  ${TG_ACCENT:-}Accent${TG_RESET:-}  ${TG_ERROR:-}Error${TG_RESET:-}"
  printf '  ~/projects/termglow %s\n' "${TG_PROMPT_CHAR:-❯}"
}

termglow_reset() {
  rm -f "$TERMGlow_THEME_FILE"
  termglow_apply_theme "$TERMGlow_DEFAULT_THEME"
  printf 'TermGlow theme reset to default: %s\n' "$TERMGlow_DEFAULT_THEME"
}

termglow_doctor() {
  local shell_name="${SHELL##*/}"
  printf 'TermGlow %s diagnostic\n\n' "$TERMGlow_VERSION"
  printf '%-18s %s\n' 'Shell' "$shell_name"
  printf '%-18s %s\n' 'Terminal' "${TERM:-unknown}"
  printf '%-18s %s\n' 'Color support' "${COLORTERM:-basic}"
  printf '%-18s %s\n' 'Active theme' "$(termglow_current_theme)"
  printf '%-18s %s\n' 'Config directory' "$TERMGlow_CONFIG_DIR"
  if command -v git >/dev/null 2>&1; then
    printf '%-18s %s\n' 'Git integration' 'available'
  else
    printf '%-18s %s\n' 'Git integration' 'not installed (optional)'
  fi
}

termglow_install() {
  local install_dir="${TERMGlow_INSTALL_DIR:-$HOME/.local/share/termglow}"
  local bin_dir="${TERMGlow_BIN_DIR:-$HOME/.local/bin}"
  local rc_file="${TERMGlow_RC_FILE:-}"
  local shell_name="${SHELL##*/}"

  case "$shell_name" in
    zsh) rc_file="${rc_file:-$HOME/.zshrc}" ;;
    bash|*) rc_file="${rc_file:-$HOME/.bashrc}" ;;
  esac

  mkdir -p "$install_dir" "$bin_dir"
  cp -R "$TERMGlow_ROOT/bin" "$TERMGlow_ROOT/lib" "$TERMGlow_ROOT/themes" "$install_dir/"
  cp "$TERMGlow_ROOT/VERSION" "$install_dir/VERSION" 2>/dev/null || printf '%s\n' "$TERMGlow_VERSION" > "$install_dir/VERSION"
  ln -sfn "$install_dir/bin/termglow" "$bin_dir/termglow"

  if ! grep -Fq "$TERMGlow_MARKER_BEGIN" "$rc_file" 2>/dev/null; then
    if [ -f "$rc_file" ]; then
      cp "$rc_file" "$rc_file.termglow-backup.$(date +%Y%m%d%H%M%S)"
    fi
    cat >> "$rc_file" <<EOF

$TERMGlow_MARKER_BEGIN
export TERMGlow_ROOT="$install_dir"
# shellcheck source=/dev/null
source "$install_dir/lib/termglow.sh"
termglow_apply_theme "\$(termglow_current_theme)"
$TERMGlow_MARKER_END
EOF
  fi

  printf 'TermGlow installed successfully.\n'
  printf 'Restart your shell or run: source %s\n' "$rc_file"
  printf 'If %s is not on PATH, add: export PATH="%s:\$PATH"\n' "$bin_dir" "$bin_dir"
}

termglow_uninstall() {
  local install_dir="${TERMGlow_INSTALL_DIR:-$HOME/.local/share/termglow}"
  local bin_dir="${TERMGlow_BIN_DIR:-$HOME/.local/bin}"
  local rc_file="${TERMGlow_RC_FILE:-$HOME/.bashrc}"
  rm -f "$bin_dir/termglow"
  rm -rf "$install_dir"
  if [ -f "$rc_file" ]; then
    sed -i "/^$TERMGlow_MARKER_BEGIN$/,/^$TERMGlow_MARKER_END$/d" "$rc_file"
  fi
  printf 'TermGlow uninstalled. Existing shell backups were preserved.\n'
}

termglow_usage() {
  cat <<'EOF'
TermGlow — a beautiful, portable Linux shell prompt manager.

Usage:
  termglow <command> [argument]

Commands:
  list                 List all available themes.
  preview [theme]      Preview a theme without saving it.
  apply <theme>        Save and activate a theme in the current shell.
  current              Show the active theme.
  reset                Restore the default theme.
  doctor               Show environment and compatibility diagnostics.
  install              Install TermGlow into ~/.local and your shell startup file.
  uninstall            Remove the installation and startup integration.
  version              Print the installed version.
  help                 Show this help message.

Examples:
  termglow list
  termglow preview neon
  termglow apply ocean
EOF
}
