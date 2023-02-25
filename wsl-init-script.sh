#!/bin/bash -i

# Description: First run script for WSL2 Ubuntu 22.04.1 LTS

NEW_HOSTNAME=lambda

DEPS=(
    build-essential
    libbz2-dev      # Python
    libffi-dev      # Python
    liblzma-dev     # Python
    libreadline-dev # Python
    libsqlite3-dev  # Python
    libssl-dev      # Python
    python3-pip     # Python
    zlib1g-dev      # Python
)

PACKAGES=(
    bat
    fd-find
    fzf
    micro
    ranger
    ripgrep
    zoxide
    apt-rollback
    nautilus
    tilix
    papirus-icon-theme
    dconf-editor
)

FISHER_PLUGINS=(
    jethrokuan/fzf
)

PIPX_PACKAGES=(
    pdm
    poetry
    black
    ruff
    pre-commit
)

ASDF_PLUGINS=(
    python
    nodejs
    nim
    # golang
    # rust
)

RED='\033[0;31m'
RESET='\033[0m'

print() {
    echo -e "${RED}$1${RESET}"
}

cd "$(dirname "$0")"

install_deps() {
    print "Updating packages..."
    sudo apt update
    sudo apt upgrade -y

    print "Installing dependencies..."
    for dep in "${DEPS[@]}"; do
        print "Installing $dep..."
        sudo apt -qq install "$dep" -y
    done
}

install_packages() {
    print "Installing packages..."
    for package in "${PACKAGES[@]}"; do
        print "Installing $package..."
        sudo apt -qq install "$package" -y
    done
}

install_pipx_packages() {
    print "Installing pipx packages..."
    sudo apt install pipx -y
    pipx ensurepath
    for package in "${PIPX_PACKAGES[@]}"; do
        pipx install "$package"
    done

}

install_fish() {
    print "Installing fish..."
    sudo apt install fish -y
    print "Changing shell to fish..."
    chsh -s $(which fish)
    mkdir -p $HOME/.config/fish
    tee $HOME/.config/fish/config.fish >/dev/null <<EOF
if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting
set -gx EDITOR micro
set PATH $PATH /home/deneb/.local/bin

function fzf-help
    echo "Ctrl-o        Find a file."
    echo "Ctrl-r        Search through command history."
    echo "Alt-c         cd into sub-directories (recursively searched)."
    echo "Alt-Shift-c   Alt-Shift-c	cd into sub-directories, including hidden ones."
    echo "Alt-o         Open a file/dir using default editor ($EDITOR)"
    echo "Alt-Shift-o   Open a file/dir using xdg-open or open command"
end

function cheat
    curl cheat.sh/\$argv
end

function wincopy
    set -l winuser '$HOSTNAME'
    set -l destination_path /mnt/c/Users/{\$winuser}/Desktop/
    mkdir -p \$destination_path
    cp -r \$argv \$destination_path
end
EOF

    # Fisher plugin manager
    print "Installing Fisher..."
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/HEAD/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

    # Install fisher plugins
    print "Installing fisher plugins..."
    for plugin in "${FISHER_PLUGINS[@]}"; do
        fish -c "fisher install $plugin"
    done
}

install_asdf() {
    print "Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch v0.11.1

    # Configure for bash
    echo . "$HOME/.asdf/asdf.sh" >>$HOME/.bashrc
    echo . "$HOME/.asdf/completions/asdf.bash" >>$HOME/.bashrc
    source $HOME/.bashrc

    # Configure for fish (requires fish)
    echo "source $HOME/.asdf/asdf.fish" >>$HOME/.config/fish/config.fish
    mkdir -p $HOME/.config/fish/completions
    ln -s $HOME/.asdf/completions/asdf.fish $HOME/.config/fish/completions
}

install_asdf_plugins() {
    print "Installing asdf plugins..."
    for plugin in "${ASDF_PLUGINS[@]}"; do
        asdf plugin add $plugin
    done

    for plugin in "${ASDF_PLUGINS[@]}"; do
        asdf install $plugin latest
        asdf global $plugin latest
    done
}

install_binaries_from_gh() {
    print "Installing binaries from GitHub..."
    mkdir -p $HOME/.local/bin

    # Tokei
    print "Installing tokei..."
    wget -qO tokei.tar.gz https://github.com/XAMPPRocky/tokei/releases/latest/download/tokei-x86_64-unknown-linux-gnu.tar.gz
    tar -xzf tokei.tar.gz -C $HOME/.local/bin
    rm tokei.tar.gz

    # Task
    print "Installing task..."
    wget -qO task.tar.gz https://github.com/go-task/task/releases/download/v3.21.0/task_linux_amd64.tar.gz
    tar -xzf task.tar.gz
    mv task $HOME/.local/bin
    cp completion/fish/task.fish $HOME/.config/fish/completions
    rm -rf task.tar.gz  LICENSE README.md completion

    # Nvim
    print "Installing nvim..."
    wget -qO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.deb
    sudo dpkg -i nvim-linux64.deb
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1

setup_gesttings() {
    print "Setting up gsettings..."
    sudo systemd-machine-id-setup
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
}

setup_wsl() {
    print "Setting up WSL..."
    sudo rm -f /etc/wsl.conf
    sudo tee /etc/wsl.conf >/dev/null <<EOF
[network]
hostname=$NEW_HOSTNAME
generateHosts=false
generateResolvConf=false
EOF

    sudo rm -f /etc/resolv.conf
    sudo tee /etc/resolv.conf >/dev/null <<EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF
    sudo chattr -f +i /etc/resolv.conf

    sudo sed -i "s/$HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
}

fix_annoyalances() {
    print "Fixing annoyances..."
    mkdir $HOME/Projects
    touch $HOME/.hushlogin

    # Bat
    ln -s $(which batcat) ~/.local/bin/bat

    # Fd
    ln -s $(which fdfind) ~/.local/bin/fd

    # Fzf-keybindings
    echo "set -U FZF_LEGACY_KEYBINDINGS 0" >>$HOME/.config/fish/config.fish

    # Zoxide
    echo "zoxide init fish | source" >>$HOME/.config/fish/config.fish
}

main() {
    install_deps
    install_packages
    install_pipx_packages
    install_fish
    sudo apt update
    install_asdf
    install_asdf_plugins
    install_binaries_from_gh
    setup_gesttings
    setup_wsl
    fix_annoyalances
    print "Done! 🙌"
    print "Please restart your WSL instance."
}

main
