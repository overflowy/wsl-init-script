# WSL2 Init Script

The script I use to streamline my fresh WSL2 (Ubuntu 22.04.1 LTS) setup.

## Usage

Clone the repository:

```shell
git clone https://github.com/overflowy/wsl-init-script.git
```

Change into the directory:

```shell
cd wsl-init-script
```

Make the script executable:

```shell
chmod +x wsl-init-script.sh
```

Run the script:

```shell
./wsl-init-script.sh
```

Restart WSL instance from PowerShell:

```powershell
wsl --shutdown
ubuntu
```

### Quick install

```shell
git clone https://github.com/overflowy/wsl-init-script.git && \
cd wsl-init-script && \
chmod +x wsl-init-script.sh && \
./wsl-init-script.sh
```

## What's included

- Permanently change the hostname to `$NEW_HOSTNAME`
- Change DNS to Cloudflare (1.1.1.1/1.0.0.1)
- Install all packages listed in `$PACKAGES` and `$DEPENDENCIES` (using **apt**)
- Install **pipx** and all the packages listed in `$PIPX_PACKAGES`
- Install **fish** shell
  - Set it as the default shell
  - Install **fisher** plugin manager
  - Install all plugins listed in `$FISHER_PLUGINS`
  - Set up some helpful aliases (such as `cheat`)
  - Set up fzf keybindings
  - Install zoxide
- Install **asdf** and all the plugins listed in `$ASDF_PLUGINS` along with the latest version for each plugin
- Fix various annoyances

## Why

Whenever I feel that my WSL2 instances has become bloated, I just run `wsl --unregister Ubuntu` and re-run the script. Nothing feels better than a clean, fresh distro.
