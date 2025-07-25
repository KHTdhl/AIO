#!/bin/bash

set -e

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
P10K_CONFIG_URL="https://raw.githubusercontent.com/KHTdhl/AIO/main/0.%E5%B8%B8%E7%94%A8%E5%B7%A5%E5%85%B7/1.%E5%B8%B8%E7%94%A8%E8%84%9A%E6%9C%AC/p10k"

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

# 安装插件
if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    echo "[+] 安装 zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    echo "[+] 安装 zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# 安装 powerlevel10k 主题
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    echo "[+] 安装 powerlevel10k 主题..."
     git clone --depth=1 --branch v1.20.0 https://ghproxy.com/https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM}/themes/powerlevel10k"
fi

# 设置默认 shell 为 zsh
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "[+] 设置 zsh 为默认 shell..."
    chsh -s "$(command -v zsh)"
fi

cd ~

# 配置 .zshrc
echo "[+] 配置 .zshrc ..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting z)' ~/.zshrc

# 加载 syntax-highlighting 插件
if ! grep -q "source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ~/.zshrc; then
    echo "source \$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi

# 下载并应用 Powerlevel10k 配置文件
echo "[+] 应用预设的 powerlevel10k 配置..."
curl -fsSL "$P10K_CONFIG_URL" -o ~/.p10k.zsh

# 确保 .zshrc 中引用 .p10k.zsh
if ! grep -q '\[ -f ~/.p10k.zsh \] && source ~/.p10k.zsh' ~/.zshrc; then
    echo '[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh' >> ~/.zshrc
fi

echo
echo "[✔] 所有插件与主题已安装！请重新打开终端或执行以下命令以生效："
echo "   source ~/.zshrc"
echo
echo "👉 Powerlevel10k 已配置完成，无需首次手动引导，终端需支持 Meslo 字体。"
