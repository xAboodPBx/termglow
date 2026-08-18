# TermGlow

TermGlow is a lightweight, portable command-line theme manager for Linux shells. It gives Bash and Zsh a polished prompt with colorful themes, Git branch awareness, error-status indicators, and a safe installation workflow that does not require root access.

## Features

TermGlow is designed to work across common Linux distributions because it uses POSIX-friendly shell utilities and installs into the user account by default. The prompt supports Bash and Zsh, detects the active shell, preserves a backup of the startup file, and can be removed without deleting user data.

The project includes six ready-to-use themes: **Aurora**, **Neon**, **Ocean**, **Sunset**, **Minimal**, and **Monochrome**. Every theme controls its own colors, symbols, Git label, and layout. The Ocean theme uses a multiline layout, while Minimal and Neon keep the prompt compact.

| Theme | Style | Layout | Best for |
|---|---|---|---|
| `aurora` | Cool cyan, violet, and green | Single line | General daily use |
| `neon` | High-contrast cyberpunk colors | Compact | Dark terminals |
| `ocean` | Calm blue palette | Multiline | Long paths and Git work |
| `sunset` | Warm orange and peach tones | Single line | Expressive desktops |
| `minimal` | Quiet grayscale with green accent | Compact | Distraction-free work |
| `monochrome` | Grayscale only | Single line | Remote or limited terminals |

## Requirements

TermGlow needs a Linux shell environment with Bash 4+ or Zsh, standard command-line utilities, and an ANSI-compatible terminal. Git is optional; when Git is installed, TermGlow displays the current branch inside a repository.

## Quick Start

Clone or extract the project, then run:

```bash
chmod +x install.sh bin/termglow
./install.sh
```

The installer copies TermGlow to `~/.local/share/termglow`, creates a command at `~/.local/bin/termglow`, and adds a small managed block to the detected shell startup file. Restart the shell, or source the startup file shown by the installer.

If `~/.local/bin` is not already on your `PATH`, add this line to your shell startup file:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Commands

```text
termglow list                 List all available themes.
termglow preview [theme]      Preview a theme without saving it.
termglow apply <theme>        Save and activate a theme.
termglow current              Show the saved theme.
termglow reset                Restore the default Aurora theme.
termglow doctor               Show shell and terminal diagnostics.
termglow install              Install the command and shell integration.
termglow uninstall            Remove TermGlow while preserving backups.
termglow version              Print the installed version.
```

Examples:

```bash
termglow list
termglow preview ocean
termglow apply neon
termglow doctor
```

## Theme Customization

A theme is a small shell file under `themes/`. It defines color variables, a symbol, a prompt character, and a layout. To create a custom theme, copy an existing file and change its values:

```bash
cp themes/aurora.theme themes/mytheme.theme
$EDITOR themes/mytheme.theme
```

The current shell loads themes from the installed copy. For local development, set `TERMGlow_ROOT` to the project directory before running the CLI:

```bash
TERMGlow_ROOT="$PWD" ./bin/termglow preview mytheme
```

## Shell Integration

The installer writes a clearly marked block into `~/.bashrc` or `~/.zshrc`. The block loads the prompt engine and applies the saved theme every time a new interactive shell starts. The original startup file is backed up before the first modification.

You can choose a different startup file during installation:

```bash
TERMGlow_RC_FILE="$HOME/.config/my-shell.rc" ./install.sh
```

The installation paths can also be overridden for packaging or testing:

```bash
TERMGlow_INSTALL_DIR="$HOME/.local/share/termglow-test" \
TERMGlow_BIN_DIR="$HOME/.local/bin" \
./install.sh
```

## Uninstall

Run:

```bash
termglow uninstall
```

This removes the installed files and the managed startup block. Timestamped startup backups are left in place so the previous configuration can be restored manually if needed.

## Testing

The repository includes lightweight tests that do not require external dependencies:

```bash
./tests/test_termglow.sh
```

The test suite checks shell syntax, theme discovery, invalid-theme handling, preview output, theme persistence, and command help.

## Project Layout

```text
termglow/
├── bin/termglow          CLI entry point
├── lib/termglow.sh       Prompt engine and installer logic
├── themes/*.theme        Built-in theme definitions
├── tests/                 Shell smoke tests
├── docs/                  Additional documentation
├── install.sh             Standalone installer
├── uninstall.sh           Standalone uninstaller
├── VERSION                Release version
└── README.md              Project documentation
```

## License

MIT License.
