# Setup Script Plan for bash-ril

Reference document for implementing a setup script that bootstraps the bash
configuration on a fresh system.

---

## Summary

Create a `setup` script in `bash-ril/` that:
- Auto-detects the distro via `/etc/os-release`
- Installs all critical and important dependencies in the correct order
- Clones the companion `scripts-ril` repo (provides custom scripts)
- Creates the `~/.bashrc` symlink (with backup of existing)
- Verifies everything is working and reports status

---

## Dependencies to Install

### Critical (config breaks without these)

| Tool | Install Method | Notes |
|------|---------------|-------|
| git | system package manager | Prerequisite for everything |
| curl | system package manager | Needed for rustup, homebrew installers |
| build-essential / base-devel | system package manager | Needed for cargo builds |
| bash-completion | system package manager | Tab completion framework |
| fzf | system package manager | Fuzzy finder for navigation + package search |
| fd-find (fdfind) | system package manager | File finder; FZF default command |
| eza | cargo install | Modern ls replacement; used everywhere |
| starship | cargo install | Shell prompt |
| Rust/Cargo (via rustup) | curl installer | Prerequisite for eza and starship |
| scripts-ril repo | git clone (SSH) | Provides across-line, wave-spark, clr, repo-header |

### Important (significant functionality added)

| Tool | Install Method | Notes |
|------|---------------|-------|
| ripgrep (rg) | system package manager | Content search; alias in config |
| nala | system package manager (Debian only) | apt replacement; heavily aliased |
| lazygit | homebrew | Terminal git UI |
| Homebrew for Linux | curl installer | Prerequisite for lazygit |

### Warn-only (not installed by script)

| Tool | Reason |
|------|--------|
| nvim (Neovim) | User installs separately (has its own config setup) |

---

## Installation Order

Order matters because some tools are prerequisites for others.

```
1. System prerequisites    git, curl, build-essential, bash-completion
2. System package tools    fzf, fd-find, ripgrep, nala (Debian)
3. Homebrew for Linux      prerequisite for lazygit
4. Rust/Cargo via rustup   prerequisite for eza, starship
5. Cargo tools             eza, starship
6. Homebrew tools          lazygit
7. Clone scripts-ril       custom scripts (across-line, wave-spark, clr, repo-header)
8. Create ~/.bashrc symlink
9. Verify & report summary
```

---

## Distro Detection

Source `/etc/os-release` to get `$ID` and `$ID_LIKE`. Map to package manager:

| Distro IDs | Package Manager | Package Install Command |
|------------|----------------|------------------------|
| debian, ubuntu, linuxmint, pop | apt | `sudo apt install -y <pkg>` |
| arch, endeavouros, manjaro | pacman | `sudo pacman -S --needed <pkg>` |

If distro is not recognized, print an error and exit (don't guess).

### Package Name Differences

| Tool | Debian package | Arch package |
|------|---------------|-------------|
| fd | fd-find | fd |
| build tools | build-essential | base-devel |
| ripgrep | ripgrep | ripgrep |
| fzf | fzf | fzf |
| bash-completion | bash-completion | bash-completion |
| nala | nala | N/A (not applicable) |

---

## Detailed Step Specifications

### Step 1: System prerequisites

```bash
# Debian/Ubuntu:
sudo apt update
sudo apt install -y git curl build-essential bash-completion

# Arch:
sudo pacman -Syu --needed git curl base-devel bash-completion
```

### Step 2: System package tools

```bash
# Debian/Ubuntu:
sudo apt install -y fzf fd-find ripgrep nala

# Arch:
sudo pacman -S --needed fzf fd ripgrep
```

- On Debian, `fd-find` provides the `fdfind` binary (which the config uses)
- On Arch, `fd` provides the `fd` binary (config uses `fdfind`, so Arch users
  may need a symlink or alias -- note this in the script output)

### Step 3: Homebrew for Linux

- Check: `command -v brew`
- If missing, install:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
- After install, eval the shellenv for the current session:
  ```bash
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ```

### Step 4: Rust/Cargo via rustup

- Check: `command -v cargo`
- If missing, install:
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  ```
- Source cargo env for current session:
  ```bash
  . "${CARGO_HOME:-$HOME/.cargo}/env"
  ```

### Step 5: Cargo tools

```bash
cargo install eza
cargo install starship --locked
```

- Check each before installing: `command -v eza`, `command -v starship`
- Skip if already installed (print "already installed" message)

### Step 6: Homebrew tools

```bash
brew install lazygit
```

- Check first: `command -v lazygit`
- Skip if already installed

### Step 7: Clone scripts-ril

- Check if `$HOME/Repos/scripts-ril` already exists
- If not:
  - Ensure `$HOME/Repos` directory exists
  - Test SSH connectivity: `ssh -T git@github.com 2>&1`
  - If SSH works: `git clone git@github.com:RilCritch/scripts-ril.git "$HOME/Repos/scripts-ril"`
  - If SSH fails: print warning about setting up SSH keys, offer HTTPS fallback:
    `git clone https://github.com/RilCritch/scripts-ril.git "$HOME/Repos/scripts-ril"`

### Step 8: Create ~/.bashrc symlink

- If `~/.bashrc` exists and is NOT already a symlink to our bashrc:
  - Back up: `cp ~/.bashrc ~/.bashrc.bak.$(date +%Y%m%d%H%M%S)`
  - Print: "Backed up existing ~/.bashrc to ~/.bashrc.bak.<timestamp>"
- If `~/.bashrc` is already a symlink to our bashrc:
  - Print: "Symlink already exists, skipping"
- Create symlink: `ln -sf "$HOME/Repos/bash-ril/bashrc" "$HOME/.bashrc"`

### Step 9: Verify & report

Check each tool and print a status table:

```
Tool            Status
─────────────────────────
git             ✓ installed
curl            ✓ installed
eza             ✓ installed
fzf             ✓ installed
fdfind          ✓ installed
starship        ✓ installed
ripgrep         ✓ installed
lazygit         ✓ installed
nala            ✓ installed
across-line     ✓ found in PATH
wave-spark      ✓ found in PATH
clr             ✓ found in PATH
repo-header     ✓ found in PATH
nvim            ⚠ not found (install separately)
~/.bashrc       ✓ symlinked to bash-ril/bashrc
```

Final message: "Setup complete. Restart your shell or run: source ~/.bashrc"

---

## Script Structure

```
setup
├── Shebang + standardized file header
├── Color output helpers (raw ANSI codes, since ansi_escape_sequences isn't sourced yet)
│   ├── info()   - cyan prefix
│   ├── ok()     - green prefix
│   ├── warn()   - yellow prefix
│   └── err()    - red prefix
├── Utility functions
│   ├── check_cmd()       - returns 0 if command exists in PATH
│   ├── detect_distro()   - sources /etc/os-release, sets DISTRO_FAMILY variable
│   └── pkg_install()     - wraps apt/pacman based on DISTRO_FAMILY
├── Section: System prerequisites
├── Section: System package tools (fzf, fd, rg, nala)
├── Section: Homebrew for Linux
├── Section: Rust/Cargo via rustup
├── Section: Cargo tools (eza, starship)
├── Section: Homebrew tools (lazygit)
├── Section: Clone scripts-ril
├── Section: Bashrc symlink
├── Section: Verification summary
└── Vim modeline footer
```

---

## Error Handling

- Each section checks if the tool is already installed before attempting
  install (idempotent -- safe to run multiple times)
- If a system package install fails: print error, continue with remaining steps
- If cargo/rustup install fails: print error, skip cargo tools, continue
- If git clone fails (SSH issue): offer HTTPS fallback, continue
- If any critical tool is missing at the end: print clear warning in summary
- Use return code `0` for success, `2` for any failures (project convention)

---

## Things the Script Will NOT Do

- Install Neovim (user handles separately)
- Install optional/niche tools (yt-dlp, numbat, glow, cxxmatrix, wally-cli,
  virtualenv, pipx, bat/batcat, kitty, qmk, etc.)
- Install distro-specific package managers (pacman, yay, paru come with distro)
- Configure SSH keys for GitHub (prerequisite user handles beforehand)
- Install or configure terminal emulators
- Modify any file other than the ~/.bashrc symlink

---

## Implementation Checklist

- [x] Create `bash-ril/setup` file with standardized header
- [x] Implement color output helpers (info, ok, warn, err)
- [x] Implement check_cmd() utility function
- [x] Implement detect_distro() -- source /etc/os-release, set DISTRO_FAMILY
- [x] Implement pkg_install() -- wrap apt/pacman based on distro
- [x] Implement Step 1: system prerequisites installation
- [x] Implement Step 2: system package tools (fzf, fd-find, ripgrep, nala)
- [x] Implement Step 3: Homebrew for Linux installation
- [x] Implement Step 4: Rust/Cargo via rustup installation
- [x] Implement Step 5: cargo tools (eza, starship)
- [x] Implement Step 6: Homebrew tools (lazygit)
- [x] Implement Step 7: Clone scripts-ril (with SSH check + HTTPS fallback)
- [x] Implement Step 8: ~/.bashrc symlink (with backup)
- [x] Implement Step 9: verification summary table
- [x] Make script executable (chmod +x)
- [x] Run `bash -n setup` to verify syntax
- [x] Run `shellcheck setup` if available -- not installed, skipped
- [x] Update AGENTS.md to document the setup script
- [ ] Test on current system (dry run) -- requires interactive terminal

---

## Notes

- The script should be idempotent: running it twice should not break anything
  or reinstall tools that are already present.
- Script uses `#!/usr/bin/env bash` shebang consistent with project conventions.
- All output uses colored messages for clarity (info=cyan, ok=green, warn=yellow,
  err=red), matching the project's ANSI color convention.
- The script does NOT source any bash-ril files during execution -- it uses
  its own inline ANSI codes since the config isn't set up yet when running.
- On Arch, `fdfind` may need a note since the binary is `fd` not `fdfind`.
  The script should check for both and suggest a symlink if needed.
- Homebrew installation is interactive by default (asks for confirmation).
  The script should note this to the user.
- Rustup with `-y` flag skips confirmation prompts for non-interactive install.
