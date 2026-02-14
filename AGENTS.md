# AGENTS.md - Coding Agent Guidelines for bash-ril

## Project Overview

Personal Bash shell configuration (dotfiles) by RilCritch. Modular design where
`bashrc` is the entry point that conditionally sources specialized files.
Root-level files handle core config; `modules/` contains split-out functions
and distro-specific aliases. Target OS is primarily Debian/Ubuntu with
Arch Linux and ArcoLinux support via conditional sourcing.

### Architecture

`bashrc` sources files in this order:

1. `envvars` + `paths` (all shells, including non-interactive)
2. `/etc/os-release` (distro detection -- sets `$ID`, `$ID_LIKE`)
3. `options`, `ansi_escape_sequences`, `aliases`, `completion`, `testing`
   (interactive shells only, after the `[[ $- != *i* ]] && return` guard)
4. Function modules: `modules/utilities`, `modules/directory_listing`,
   `modules/fzf_navigation`, `modules/navigation`, `modules/file_manipulation`
5. Cross-distro modules: `modules/aliases_flatpak`
6. Distro-specific modules: `modules/aliases_arch`, `modules/aliases_debian`,
   or `modules/aliases_arcolinux` (conditional on `$ID`)
7. Initializes Starship prompt, runs startup display

### Directory Structure

```
bash-ril/
  bashrc                        # entry point, sources everything
  envvars                       # environment variable exports
  paths                         # PATH management
  options                       # shell options (shopt, bind)
  ansi_escape_sequences         # ANSI color/style variables
  aliases                       # universal aliases (cross-distro)
  completion                    # tab-completion setup
  testing                       # scratch pad for experimental code
  modules/
    utilities                   # get-dir-h, get-dir-c, is_number, tree-size
    directory_listing           # lsr, lst, clsr, clst, dir-overview, etc.
    fzf_navigation              # dir-nav-fzf, d, n (fzf-powered cd)
    navigation                  # up (move up directories)
    file_manipulation           # ex (archive extractor)
    aliases_flatpak             # flatpak aliases + flatf (always sourced)
    aliases_arch                # pacman/yay/paru aliases + pacf/aurf
    aliases_debian              # nala/apt aliases + ddf
    aliases_arcolinux           # arcolinux app aliases and fixes
```

### Key External Dependencies

fzf, fdfind, eza, starship, ripgrep (rg), bat/batcat, lazygit, neovim (nvim)

### Setup Script

The `setup` script bootstraps a fresh system with all required dependencies:

```bash
./setup
```

What it installs:
- System prerequisites: git, curl, build-essential/base-devel, bash-completion
- System tools: fzf, fd-find/fd, ripgrep, nala (Debian only)
- Homebrew for Linux (prerequisite for lazygit)
- Rust/Cargo via rustup (prerequisite for cargo tools)
- Cargo tools: eza, starship
- Homebrew tools: lazygit
- Clones `scripts-ril` repo (provides custom scripts: across-line, wave-spark, clr, repo-header)
- Creates `~/.bashrc` symlink (backs up existing)

Requirements before running:
- sudo access
- SSH key configured on GitHub (for cloning scripts-ril; HTTPS fallback available)

---

## Build / Lint / Test Commands

There is no build system, no CI/CD pipeline, and no formal test framework.
The project is a collection of Bash files sourced directly by the shell.

### Validating Changes

```bash
# Syntax-check a single file (catches parse errors without executing)
bash -n <file>

# Syntax-check all source files
bash -n bashrc envvars paths options ansi_escape_sequences aliases completion testing
bash -n modules/*

# Lint with shellcheck (if installed)
shellcheck <file>
shellcheck -s bash bashrc envvars paths options aliases completion testing modules/*

# Test by sourcing into a new interactive shell
bash --rcfile bashrc
```

### Testing Experimental Code

The `testing` file is used as a scratch pad for experimental functions. New
functions should be prototyped there before being moved to the appropriate
module in `modules/`.

---

## Code Style Guidelines

### Language & Shebang

- All files are **Bash**. Use `#!/usr/bin/env bash`.

### File Naming

- **All lowercase**, no file extensions.
- **Underscores** for multi-word names: `ansi_escape_sequences`, `fzf_navigation`.
- Root-level files for core config; `modules/` for functions and distro-specific code.

### File Header

Every file should include a header block:

```bash
#!/usr/bin/env bash

# Description ->
#
# |- Summary: Brief description of what this file contains
#
# |- Dependencies:
#             - list external tools required

# Document Info ->
#
# |- Author: RilCritch
#
# |- Last Update: MM/DD/YYYY
```

### Vim Modelines

Every file ends with:

```bash
# Vim options - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# vim: ts=4 sts=4 sw=4 et
# vim:fileencoding=utf-8:foldmethod=marker
```

### Indentation & Formatting

- **4 spaces** for indentation (no tabs).

### Code Organization / Folding

Sections use **vim fold markers**: `{{{`/`}}}`, nested as `{{{{`/`}}}}`.
Section headers use comment-decorated styles: `# |- Description ->`

### Imports / Sourcing

Always guard-before-source. Use `.` (dot) not `source`:

```bash
[[ -f "${BASH_HOME}/somefile" ]] && . "${BASH_HOME}/somefile"
```

### Function Naming

- **Kebab-case** for most functions: `get-dir-h`, `dir-nav-fzf`, `dir-overview`
- **Short abbreviated names** for frequent interactive use: `d`, `n`, `up`, `ex`
- **snake_case** acceptable for pure utility functions: `is_number`

### Variable Naming

- **UPPER_SNAKE_CASE** for environment/exported variables: `BASH_HOME`, `XDG_DATA_HOME`
- **lower_snake_case** for local/function-scoped variables: `dir_name`, `dir_path`
- **lowercase** for ANSI color constants: `red`, `cyan`, `reset`, `bold`
  - Prefixes: `l_` = light, `b_` = background, `b_l_` = light background
- Declare function-scoped variables with `local`.

### Alias Naming

- Short lowercase abbreviations: `ls`, `ll`, `lg`, `nv`, `cc`, `c`
- Concatenated lowercase for compound names: `lineacross`, `pacup`, `updateall`
- Do NOT use hyphens in aliases (hyphens are for functions).

### Error Handling

1. **Guard + colored error message + `return 2`** (standard pattern):
   ```bash
   if [[ -z "$dir_name" ]]; then
       echo -e "${red}ERROR: ${reset}Specified Directory ${blue}${1} ${reset}does not exist."
       return 2
   fi
   ```
2. **`cd ... || return 2`** for directory changes.
3. **Return empty string** from helpers to signal failure; caller checks
   with `[[ -z "$result" ]]`.
4. **Suppress stderr** when failure is expected: `2> /dev/null`
5. Use return code **`2`** as the standard error exit code (not `1`).

### Quoting & Conditionals

- Always double-quote variable expansions: `"${dir_name}"`, `"$1"`
- Prefer `[[ ... ]]` over `[ ... ]` for conditionals.
- Use `==` for string equality, `=~` for regex inside `[[ ... ]]`.
- Use `&&` short-circuit for simple one-liners; `if`/`then`/`fi` for multi-line.

### Output & Colors

- Use `echo -e` with ANSI variables for colored output.
- Color variables from `ansi_escape_sequences` are available globally.
- Always `${reset}` after colored text segments.

### Adding New Functionality

- **New functions** go in the appropriate `modules/` file (or `testing` for
  prototyping). If no module fits, create a new one and add a guarded source
  line in `bashrc`.
- **New universal aliases** go in `aliases`, under the appropriate `{{{` section.
- **New distro-specific aliases/functions** go in `modules/aliases_<distro>`.
- **New env vars** go in `envvars`; new PATH entries go in `paths`.
- Keep the sourcing order: envvars/paths first, then interactive-only files,
  then modules (utilities before modules that depend on them).

### Distro-Specific Code

Distro detection is done by sourcing `/etc/os-release` which sets `$ID`.
Conditional sourcing in `bashrc` uses a `case` statement on `$ID`:
- `arch|endeavouros|manjaro` -> `modules/aliases_arch`
- `debian|ubuntu|linuxmint|pop` -> `modules/aliases_debian`
- `arcolinux` -> `modules/aliases_arcolinux`
- `modules/aliases_flatpak` is always sourced (cross-distro)

To add a new distro, create `modules/aliases_<distro>` and add a case branch.

### Things to Avoid

- Do not add file extensions to shell config files.
- Do not use `source` keyword; use `.` (dot) instead.
- Do not hardcode paths when a variable like `$HOME` or `$BASH_HOME` is available.
- Do not break the interactive shell guard in `bashrc` (line 19).
