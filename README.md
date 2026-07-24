# Dotfiles

These are my personal config files. I use [chezmoi](https://www.chezmoi.io/) to keep them in sync across my computers.

They set up:

- Git and tig
- Ghostty
- Neovim
- tmux
- pi

These files are mainly made for Linux.

## What to install first

Install these before using the config:

- [chezmoi](https://www.chezmoi.io/)
- Git
- [git-delta](https://github.com/dandavison/delta)
- Ghostty
- Neovim 0.12 or newer
- tmux
- [pi](https://pi.dev/)
- [JetBrains Mono Nerd Font](https://www.nerdfonts.com/font-downloads)

`tig` is optional. Install `ripgrep` if you want to search file contents from Neovim.

## Set up a new computer

Run:

```sh
chezmoi init --apply cocoastorm
```

Neovim downloads its add-ons the first time it starts. It also installs support for Bash, JSON, TOML, and YAML. Go support is added when Go is installed.

## Set up tmux

The tmux config uses [TPM](https://github.com/tmux-plugins/tpm) to install a few tmux add-ons.

Install TPM:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Start tmux, then press `Ctrl-Space` followed by `Shift-I`.

The first key is the tmux prefix. The second key installs the add-ons listed in `~/.config/tmux/tmux.conf`.

The config uses `xdg-open` when you click a link in tmux. This command normally comes with a Linux desktop.

## Git work settings

Repos inside `~/powerbill/` use the work email address and the ignore file in `~/.config/git/powerbill.gitignore`.

Repos outside that folder use the personal email address.

## pi settings

The pi settings include several add-ons. pi downloads the npm add-ons itself.

One entry points to `~/agent-stuff`. That folder is not part of this repo nor it is on Github, so remove that entry on a computer where it does not exist.

Login details and API keys are not stored in this repo. Set those up separately.

## Get the latest changes

```sh
chezmoi update
```

## Save a change

After changing a managed file, copy that file into chezmoi. For example:

```sh
chezmoi re-add ~/.config/tmux/tmux.conf
```

Use `chezmoi add <file>` when you want to start tracking a new file.

Then review and send it to GitHub:

```sh
chezmoi cd
git status
git diff
git add .
git commit -m "Update dotfiles"
git push
exit
```
