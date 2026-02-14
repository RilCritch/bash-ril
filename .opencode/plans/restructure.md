# Restructuring Plan for bash-ril

Reference document for implementing structural improvements to the bash
configuration. Check items off as they are completed.

---

## Summary of Changes

- Unify `BASH_PATH`/`BASH_HOME` into a single variable (`BASH_HOME`)
- Split `functions` (522 lines) into focused modules in a `modules/` subdirectory
- Extract distro-specific aliases and functions into conditionally-sourced files
- Add distro detection via `/etc/os-release`
- Replace all hardcoded `/home/rc/` paths with `$HOME`
- Add `local` declarations to all function-scoped variables
- Standardize file headers across all files
- Remove redundant sourcing of `ansi_escape_sequences` in functions
- Update `bashrc` sourcing to reflect new structure
- Update `AGENTS.md` to reflect all changes

---

## New Directory Layout

```
bash-ril/
  .bash_profile                 # unchanged
  bashrc                        # updated sourcing, distro detection
  envvars                       # unchanged content, standardized header
  paths                         # unchanged content, standardized header
  options                       # unchanged content, standardized header
  ansi_escape_sequences         # unchanged
  aliases                       # universal aliases only (distro sections removed)
  completion                    # unchanged content, standardized header
  testing                       # unchanged
  modules/
    utilities                   # get-dir-h, get-dir-c, is_number, tree-size
    directory_listing           # lsr, lsra, clsr, clsra, lst, clst, clsta, dir-overview
    fzf_navigation              # dir-nav-fzf, dir-nav-fzf-hid, d, n
    navigation                  # up
    file_manipulation           # ex
    aliases_flatpak             # flatpak aliases + flatf function
    aliases_arch                # pacman/yay/paru aliases + pacf/aurf functions
    aliases_debian              # nala/apt aliases + ddf function
    aliases_arcolinux           # arcolinux app aliases and fixes
  README.md
  TODOS.md
  AGENTS.md
```

---

## Sourcing Order in bashrc

This order matters due to dependencies between files.

```
1. BASH_HOME set at top of bashrc
2. envvars              (defines BASH_HOME export, XDG_*, etc.)
3. paths                (uses $HOME)
4. /etc/os-release      (sets $ID, $ID_LIKE for distro detection)
   --- [[ $- != *i* ]] && return ---
5. options
6. ansi_escape_sequences
7. aliases              (universal only)
8. completion
9. testing
10. modules/utilities            (standalone helpers, no deps)
11. modules/directory_listing    (depends on utilities)
12. modules/fzf_navigation       (depends on utilities)
13. modules/navigation           (independent)
14. modules/file_manipulation    (independent)
15. modules/aliases_flatpak      (always sourced, cross-distro)
16. modules/aliases_<distro>     (conditional on $ID)
17. starship init
18. startup display
```

---

## Standardized File Header Template

Apply to every file (root and modules/):

```bash
#!/usr/bin/env bash

# Description ->
#
# |- Summary: <brief description>
#
# |- Dependencies:
#             - <list or "none">

# Document Info ->
#
# |- Author: RilCritch
#
# |- Last Update: <MM/DD/YYYY>
```

Every file ends with:

```bash
# Vim options - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# vim: ts=4 sts=4 sw=4 et
# vim:fileencoding=utf-8:foldmethod=marker
```

---

## Implementation Checklist

### Phase 1: Setup

- [x] Create `modules/` directory
- [x] Unify `BASH_PATH` -> `BASH_HOME`
    - [x] Change `bashrc:5` from `BASH_PATH=...` to `BASH_HOME=...`
    - [x] Replace all `${BASH_PATH}` references in `bashrc` with `${BASH_HOME}`
    - [x] Remove the redundant `BASH_HOME` export from `envvars:25` (keep it in
          bashrc as the canonical definition; envvars can re-export it)

### Phase 2: Split functions into modules/

Each new file gets the standardized header, vim modeline footer, and fold
markers where appropriate. All function variables get `local` declarations.

- [x] **modules/utilities** -- extract from `functions`:
    - `get-dir-h` (lines 35-45)
    - `get-dir-c` (lines 50-60)
    - `is_number` (lines 68-74)
    - `tree-size` (lines 82-110) -- add `local` to: `dir_name`, `extra_lines`,
      `term_height`, `height`

- [x] **modules/directory_listing** -- extract from `functions`:
    - `lsr` (lines 121-130)
    - `lsra` (lines 132-141)
    - `clsr` (lines 143-153)
    - `clsra` (lines 155-173)
    - `lst` (lines 178-187)
    - `clst` (lines 189-199)
    - `clsta` (lines 201-211)
    - `dir-overview` (lines 219-285) -- add `local` to: `dir_name`,
      `extra_lines`, `input`, `dir_path`, `num_files`, `num_dirs`, `num_links`,
      `tree_height`, `dir_length`, `files_length`, `dirs_length`,
      `links_length`, `linewidth`

- [x] **modules/fzf_navigation** -- extract from `functions`:
    - `dir-nav-fzf` (lines 294-309) -- add `local` to: `dir_name`, `dir_path`,
      `choice`
    - `dir-nav-fzf-hid` (lines 311-326) -- add `local` to: `dir_name`,
      `dir_path`, `choice`
    - `d` (lines 328-380) -- add `local` to: `dir_name`, `dir_path`, `choice`,
      `dir_traversal`, `dir_number`, `repo_path`, `header_size`, `extra_lines`
    - `n` (lines 407-416) -- add `local` to: `choice`
    - Replace `/home/rc/Repos/notes-ril` with `$HOME/Repos/notes-ril` in `n()`
    - Keep commented-out `r()` function (lines 382-404) as-is

- [x] **modules/navigation** -- extract from `functions`:
    - `up` (lines 468-485) -- already uses `local`

- [x] **modules/file_manipulation** -- extract from `functions`:
    - `ex` (lines 493-515) -- no local vars needed (uses $1 directly)

- [x] Delete the old `functions` file after all modules are created and verified

### Phase 3: Extract distro-specific aliases and functions

- [x] **modules/aliases_arch** -- extract:
    - From `aliases`: pacman aliases (lines 166-174), yay aliases (lines 177-179),
      paru aliases (lines 182-184), package info aliases (lines 187-190)
    - From `functions`: `pacf` (lines 435-442), `aurf` (lines 445-452)
    - Add `local` to `choice` in `pacf` and `aurf`

- [x] **modules/aliases_debian** -- extract:
    - From `aliases`: nala/apt aliases (lines 197-205)
    - From `functions`: `ddf` (lines 424-432)
    - Add `local` to `choice` in `ddf`

- [x] **modules/aliases_arcolinux** -- extract:
    - From `aliases`: entire arcolinux section (lines 328-355) -- apps + fixes

- [x] **modules/aliases_flatpak** -- extract:
    - From `aliases`: flatpak aliases (lines 208-211)
    - From `functions`: `flatf` (lines 454-461)
    - Add `local` to `choice` in `flatf`

- [x] Remove extracted sections from `aliases` (leave the rest as universal)

### Phase 4: Update bashrc

- [x] Add distro detection after sourcing `envvars`/`paths`:
    ```bash
    [[ -f /etc/os-release ]] && . /etc/os-release
    ```
- [x] Replace the single `functions` source line with individual module sources:
    ```bash
    [[ -f "${BASH_HOME}/modules/utilities" ]] && . "${BASH_HOME}/modules/utilities"
    [[ -f "${BASH_HOME}/modules/directory_listing" ]] && . "${BASH_HOME}/modules/directory_listing"
    [[ -f "${BASH_HOME}/modules/fzf_navigation" ]] && . "${BASH_HOME}/modules/fzf_navigation"
    [[ -f "${BASH_HOME}/modules/navigation" ]] && . "${BASH_HOME}/modules/navigation"
    [[ -f "${BASH_HOME}/modules/file_manipulation" ]] && . "${BASH_HOME}/modules/file_manipulation"
    ```
- [x] Add always-sourced cross-distro modules:
    ```bash
    [[ -f "${BASH_HOME}/modules/aliases_flatpak" ]] && . "${BASH_HOME}/modules/aliases_flatpak"
    ```
- [x] Add conditional distro sourcing:
    ```bash
    case "${ID}" in
        arch|endeavouros|manjaro)
            [[ -f "${BASH_HOME}/modules/aliases_arch" ]] && . "${BASH_HOME}/modules/aliases_arch"
            ;;
        debian|ubuntu|linuxmint|pop)
            [[ -f "${BASH_HOME}/modules/aliases_debian" ]] && . "${BASH_HOME}/modules/aliases_debian"
            ;;
    esac
    [[ "${ID}" == "arcolinux" ]] && \
        [[ -f "${BASH_HOME}/modules/aliases_arcolinux" ]] && . "${BASH_HOME}/modules/aliases_arcolinux"
    ```

### Phase 5: Hardcoded paths

Replace `/home/rc/` with `$HOME` in `aliases`:

- [x] Line 55: `d /home/rc/Documents` -> `d "$HOME/Documents"`
- [x] Line 56: `d /home/rc/Builds` -> `d "$HOME/Builds"`
- [x] Line 57: `d /home/rc/Repos` -> `d "$HOME/Repos"`
- [x] Line 59: `d /home/rc/.config` -> `d "$HOME/.config"`
- [x] Line 60: `d /home/rc/.local` -> `d "$HOME/.local"`
- [x] Line 89: `cd /home/rc/.config/qmk/...` -> `cd "$HOME/.config/qmk/..."`
- [x] Line 93-94: `nvim /home/rc/Repos/bash-ril/...` -> `nvim "$BASH_HOME/..."`
- [x] Line 219: okolors hardcoded path -> use `$HOME`
- [x] Also fix hardcoded paths in `modules/fzf_navigation` (the `n()` function)

### Phase 6: Standardize headers

Apply the standardized header template and vim modeline footer to:

- [x] `bashrc`
- [x] `envvars`
- [x] `paths`
- [x] `options`
- [x] `ansi_escape_sequences`
- [x] `aliases`
- [x] `completion`
- [x] `modules/utilities`
- [x] `modules/directory_listing`
- [x] `modules/fzf_navigation`
- [x] `modules/navigation`
- [x] `modules/file_manipulation`
- [x] `modules/aliases_flatpak`
- [x] `modules/aliases_arch`
- [x] `modules/aliases_debian`
- [x] `modules/aliases_arcolinux`

### Phase 7: Finalize

- [x] Update `AGENTS.md` to reflect new structure, modules/ convention, distro
      detection, and updated sourcing order
- [x] Run `bash -n` on all files to verify syntax
- [x] Run `shellcheck -s bash` on all files (if available) -- shellcheck not installed, skipped
- [ ] Verify interactive shell works: `bash --rcfile bashrc` -- requires interactive terminal
- [x] Update `TODOS.md` -- mark completed items

---

## Notes

- **Commented-out code**: Leave all commented-out code as-is. Do not remove.
- **testing file**: Leave completely unchanged (it's a scratch pad).
- **.bash_profile**: Leave unchanged.
- **ansi_escape_sequences**: Content unchanged. Already has a minimal header
  which will be expanded to match the standard template.
- **Distro detection**: Sourcing `/etc/os-release` directly sets `$ID` and
  `$ID_LIKE` as shell variables. This is the standard portable method.
  `ID_LIKE` can be used for derivative distros (e.g., Ubuntu sets
  `ID_LIKE=debian`). The case statement in bashrc should handle this.
- **BASH_HOME lifecycle**: Set in `bashrc` before anything is sourced. `envvars`
  re-exports it so it's available to child processes. Both definitions point to
  the same value.
