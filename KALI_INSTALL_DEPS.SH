#!/usr/bin/zsh

sudo apt install pipx -y
py -m pip install --user pipx
pipx ensurepath
pipx install pyright
pipx install boto3 --include-deps
pipx install pyfunctional

# Making mono binaries work without mono prefix --------------------------------

# Enable running Mono/.NET PE files directly (no 'mono' prefix) via binfmt_misc.
# Works on Debian/Ubuntu/Kali with systemd or without. Idempotent.
set -euo pipefail

NAME="cli"                          # binfmt entry name
INTERP="/usr/bin/mono"              # interpreter to launch
RULE=":${NAME}:M::MZ::${INTERP}:"   # magic-based rule (match 'MZ' at offset 0)

usage() {
  cat <<EOF
Usage:
  sudo $0              Install and enable Mono binfmt rule (persistent)
  sudo $0 --uninstall  Remove rule and cleanup
  sudo $0 --no-apt     Skip any attempts to apt-install mono/runtime helpers

Notes:
- This maps any PE 'MZ' binary to Mono. If you use Wine for Windows .exe files,
  this may intercept them. See the warning printed during install.
- After install, ensure your compiled outputs are executable: chmod +x yourapp
- Compile as usual with mcs/csc, e.g. mcs -out:/usr/local/bin/mcrypt file.cs
EOF
}

want_apt=1
do_uninstall=0
[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && { usage; exit 0; }
[[ "${1:-}" == "--uninstall" ]] && do_uninstall=1
[[ "${1:-}" == "--no-apt"   ]] && want_apt=0

require_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "Re-running as root..."
    exec sudo -E "$0" "${@}"
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

apt_install_if_missing() {
  local bin="$1" pkg1="$2" pkg2="${3:-}"
  if [[ ! -x "$bin" ]]; then
    [[ $want_apt -eq 1 && $(have apt-get && echo yes || echo no) == "yes" ]] || return 0
    apt-get update -y
    apt-get install -y "$pkg1" || { [[ -n "$pkg2" ]] && apt-get install -y "$pkg2" || true; }
  fi
}

ensure_kernel_binfmt() {
  # Ensure binfmt_misc is mounted/enabled
  if [[ ! -d /proc/sys/fs/binfmt_misc ]]; then
    modprobe binfmt_misc || true
  fi
  if [[ ! -e /proc/sys/fs/binfmt_misc/register ]]; then
    # Try to mount if not yet mounted (non-systemd cases)
    mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null || true
  fi
  if [[ ! -e /proc/sys/fs/binfmt_misc/register ]]; then
    echo "ERROR: binfmt_misc not available (no register node). Kernel/module missing?"
    exit 1
  fi
}

register_rule_runtime() {
  # Remove existing entry if present
  if [[ -e /proc/sys/fs/binfmt_misc/${NAME} ]]; then
    echo -1 > /proc/sys/fs/binfmt_misc/${NAME} || true
  fi
  # Register fresh
  echo "${RULE}" > /proc/sys/fs/binfmt_misc/register
}

persist_rule() {
  mkdir -p /etc/binfmt.d
  echo "${RULE}" > /etc/binfmt.d/mono-cli.conf
  if have systemctl; then
    systemctl restart systemd-binfmt || true
  else
    # Non-systemd: ensure runtime registration too
    ensure_kernel_binfmt
    register_rule_runtime
  fi
}

unpersist_rule() {
  rm -f /etc/binfmt.d/mono-cli.conf
  if [[ -e /proc/sys/fs/binfmt_misc/${NAME} ]]; then
    echo -1 > /proc/sys/fs/binfmt_misc/${NAME} || true
  fi
  if have systemctl; then
    systemctl restart systemd-binfmt || true
  fi
}

verify() {
  echo "=== Verification ==="
  if [[ -e /proc/sys/fs/binfmt_misc/${NAME} ]]; then
    echo "binfmt entry '${NAME}' is active:"
    cat /proc/sys/fs/binfmt_misc/${NAME}
  else
    echo "WARN: '${NAME}' entry not found under /proc/sys/fs/binfmt_misc; trying to register live..."
    ensure_kernel_binfmt
    register_rule_runtime
    [[ -e /proc/sys/fs/binfmt_misc/${NAME} ]] && cat /proc/sys/fs/binfmt_misc/${NAME}
  fi
  echo "binfmt_misc status:"
  [[ -e /proc/sys/fs/binfmt_misc/status ]] && cat /proc/sys/fs/binfmt_misc/status || echo "unknown"
}

warn_wine() {
  if have wine || have wine64; then
    echo "WARNING: Wine detected on this system."
    echo "Mapping all 'MZ' binaries to Mono may intercept some Windows executables."
    echo "If that becomes a problem, run: sudo $0 --uninstall"
    echo
  fi
}

main_install() {
  require_root "$@"

  # Ensure Mono runtime exists (so /usr/bin/mono is present)
  if [[ ! -x "${INTERP}" ]]; then
    echo "Mono interpreter not found at ${INTERP}."
    echo "Attempting to install (mono-runtime, falling back to mono-complete)..."
    apt_install_if_missing "${INTERP}" mono-runtime mono-complete
    if [[ ! -x "${INTERP}" ]]; then
      echo "ERROR: Mono not found and couldn't be installed automatically. Install Mono then re-run."
      exit 1
    fi
  fi

  warn_wine

  # Make it persistent and active
  persist_rule
  verify

  echo
  echo "Done. You can now run compiled C# assemblies directly (no 'mono' prefix)."
  echo "Remember to make them executable if you place them in PATH, e.g.:"
  echo "  chmod +x /usr/local/bin/yourapp"
}

main_uninstall() {
  require_root "$@"
  unpersist_rule
  echo "Removed Mono binfmt rule '${NAME}'."
}

if [[ $do_uninstall -eq 1 ]]; then
  main_uninstall "$@"
else
  main_install "$@"
fi

#-------------------------------------------------------------------------------
