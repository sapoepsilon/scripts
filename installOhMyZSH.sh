#!/bin/sh -e

echo "What is your OS? (Enter 1 for macOS or 2 for Ubuntu)"
read os

while [ "$os" != "1" ] && [ "$os" != "2" ]; do
    echo "Invalid input. Please enter 1 for macOS or 2 for Ubuntu."
    read os
done

if [ $os = "1" ]; then
    echo "You have selected macOS"
    if ! [ -x "$(command -v git)" ]; then
        echo "Error: git is not installed. Please install git and run the script again."
        exit 1
    fi
    if ! [ -x "$(command -v brew)" ]; then
        echo "Error: brew is not installed. Please install brew and run the script again."
        exit 1
    fi
    echo "Installing ZSH"
    brew install zsh
    echo "Setting ZSH as default shell"
    chsh -s $(which zsh)
    echo "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ $? -eq 0 ]; then
        echo "Installing Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k/powerlevel10k/g' ~/.zshrc
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc
        echo "Installing plugins"
        sed -i '' 's/plugins=(git)/plugins=(git jump zsh-autosuggestions sublime zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)/g' ~/.zshrc
        echo "Please restart your terminal for changes to take effect"
        # code for macOS
    else
        echo "Error installing Oh My Zsh"
        exit 1
    fi
elif [ $os = "2" ]; then

    # code for Debian
    echo "Checking for git..."
    if ! [ -x "$(command -v git)" ]; then
        echo "Error: git is not installed. Please install git and run the script again."
        echo "Installing git..."
        sudo apt-get install git
        exit 1
    fi
    echo "Installing ZSH"
    sudo apt-get install zsh
    echo "Setting ZSH as default shell"
    chsh -s $(which zsh)
    echo "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    if [ $? -eq 0 ]; then
        echo "Installing Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        sed -i -e 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k/powerlevel10k/g' ~/.zshrc ~/.zshrc
        echo "Installing plugins"
        sed -i -e 's/plugins=(git)/plugins=(git jump zsh-autosuggestions sublime zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)/g' ~/.zshrc
        echo "Please restart your terminal for changes to take effect"
    fi
else
    echo "Error installing Oh My Zsh"
fi
