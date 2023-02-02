#!/bin/sh

echo "What is your OS? (Enter 1 for macOS or 2 for Ubuntu)"
read os

while [ "$os" != "1" ] && [ "$os" != "2" ]; do
    echo "Invalid input. Please enter 1 for macOS or 2 for Ubuntu."
    read os
done

if [ $os = "1" ]; then
    echo "You have selected macOS"
    if ! which brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "Homebrew found."
    fi
    if ! which git >/dev/null; then
        echo "Git not found. Installing..."
        brew install git
    else
        echo "Git found."
    fi
    version=$(sw_vers -productVersion)

    if [[ "$version" < "10.15" ]]; then
        echo "macOS version is Catalina or older"
        echo "Setting ZSH as default shell"
        brew install zsh
        chsh -s $(which zsh)
    else
        echo "macOS version is newer than Catalina"
    fi

    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh already installed"
    else
        echo "Installing Oh My Zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
        wait
        if [ $? -eq 0 ]; then
            echo "Successfully installed Oh My Zsh"
        else
            echo "Error installing Oh My Zsh"
        fi
    fi
    if [ $? -eq 0 ]; then
        echo "Installing Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        sed -i '' 's#robbyrussell#powerlevel10k/powerlevel10k#g' ~/.zshrc
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc
        echo "Installing plugins"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        sed -i '' 's/plugins=(git)/plugins=(git jump zsh-autosuggestions sublime zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)/g' ~/.zshrc
        echo "Please restart your terminal for changes to take effect"
        # code for macOS
    else
        echo "Error installing Oh My Zsh"
        exit 1
    fi
    echo "Installing raycast"
    brew install raycast

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
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh already installed"
    else
        echo "Installing Oh My Zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
        wait
        if [ $? -eq 0 ]; then
            echo "Successfully installed Oh My Zsh"
        else
            echo "Error installing Oh My Zsh"
        fi
    fi
    if [ $? -eq 0 ]; then
        echo "Installing Powerlevel10k"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        sed -i -e 's#robbyrussell#powerlevel10k/powerlevel10k#g' ~/.zshrc
        echo "Installing plugins"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        sed -i -e 's/plugins=(git)/plugins=(git jump zsh-autosuggestions sublime zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)/g' ~/.zshrc
        echo "Please restart your terminal for changes to take effect"
    fi
else
    echo "Error installing Oh My Zsh"
fi
