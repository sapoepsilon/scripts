#!/bin/sh

echo "What is your OS? (Enter 1 for macOS, 2 for Ubuntu, 3 for Fedora, or 4 for Arch Linux)"
read os

while [ "$os" != "1" ] && [ "$os" != "2" ] && [ "$os" != "3" ] && [ "$os" != "4" ]; do
    echo "Invalid input. Please enter 1 for macOS, 2 for Ubuntu, 3 for Fedora, or 4 for Arch Linux."
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
    echo "Installing iterm2"
    brew install iterm2
    brew install fzf

elif [ $os = "2" ]; then

    # code for Ubuntu
    echo "Checking for git..."
    if ! [ -x "$(command -v git)" ]; then
        echo "Error: git is not installed. Please install git and run the script again."
        echo "Installing git..."
        sudo apt-get install git
        exit 1
    fi
    echo "Install fzf"
    sudo apt-get install fzf
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

elif [ $os = "3" ]; then


    # code for Fedora
    echo "Checking for git..."
    if ! [ -x "$(command -v git)" ]; then
        echo "Error: git is not installed. Please install git and run the script again."
        echo "Installing git..."
        sudo dnf install git
        exit 1
    fi
    echo "Installing ZSH"
    sudo dnf install zsh
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

elif [ $os = "4" ]; then
    echo "You have selected Arch Linux"
    
    # Verificar si git está instalado
    if ! command -v git &> /dev/null; then
        echo "Git not found. Installing..."
        sudo pacman -S --noconfirm git
    else
        echo "Git found."
    fi

    # Instalar fzf
    echo "Installing fzf"
    sudo pacman -S --noconfirm fzf

    # Instalar ZSH si no está instalado
    if ! command -v zsh &> /dev/null; then
        echo "Installing ZSH"
        sudo pacman -S --noconfirm zsh
    else
        echo "ZSH already installed."
    fi

    # Cambiar el shell predeterminado a ZSH
    echo "Setting ZSH as default shell"
    chsh -s $(which zsh)
    echo "Your default shell is now " 
    echo $SHELL

    # Instalar Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo "Oh My Zsh already installed"
    fi

    # Instalar Powerlevel10k
    echo "Installing Powerlevel10k"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

    # Instalar plugins
    echo "Installing plugins"
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git jump zsh-autosuggestions zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)/g' ~/.zshrc

    echo "Please restart your terminal for changes to take effect"

else
    echo "Error installing Oh My Zsh"
fi
