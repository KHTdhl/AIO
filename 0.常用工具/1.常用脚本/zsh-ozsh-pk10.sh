#!/bin/bash

set -e

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[+] 检查 zsh 是否安装..."
if ! command -v zsh >/dev/null 2>&1; then
    echo "[!] 未安装 zsh，开始安装..."
    if command -v apt >/dev/null; then
        sudo apt update && sudo apt install -y zsh git curl fonts-powerline
    elif command -v dnf >/dev/null; then
        sudo dnf install -y zsh git curl powerline-fonts
    elif command -v pacman >/dev/null; then
        sudo pacman -S --noconfirm zsh git curl powerline-fonts
    else
        echo "[✘] 不支持的发行版，请手动安装 zsh。"
        exit 1
    fi
fi

# 安装 oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "[+] 安装 oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "[=] 已安装 oh-my-zsh"
fi

# 安装 zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    echo "[+] 安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

# 安装 zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    echo "[+] 安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# 安装 powerlevel10k
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    echo "[+] 安装 powerlevel10k 主题..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
fi

# 设置默认 shell 为 zsh
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "[+] 设置 zsh 为默认 shell..."
    chsh -s "$(command -v zsh)"
fi

cd ~

# 更新 .zshrc 插件和主题配置
echo "[+] 配置 .zshrc ..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)' ~/.zshrc

# 加载 syntax-highlighting 插件
if ! grep -q "source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ~/.zshrc; then
    echo "source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi

echo "[✔] 所有插件与主题已安装！请重新打开终端或执行："
echo "   source ~/.zshrc"
echo
echo "👉 Powerlevel10k 会首次启动时自动引导配置（终端需支持 Meslo 字体）"
