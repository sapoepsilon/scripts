#!/bin/sh

#!/bin/sh

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

echo "${YELLOW}What is your OS? (Enter 1 for macOS, 2 for Ubuntu, 3 for Fedora, or 4 for Arch Linux)${NC}"
read os

while [ "$os" != "1" ] && [ "$os" != "2" ] && [ "$os" != "3" ] && [ "$os" != "4" ]; do
    echo "${RED}Invalid input. Please enter 1 for macOS. 2 for Ubuntu, 3 for Fedora, or 4 for Arch Linux.${NC}"
    read os
done
if [ $os = "1" ]; then
    echo "${GREEN}You have selected macOS${NC}"

    # Check for Homebrew installation
    if ! which brew >/dev/null; then
        echo "${YELLOW}Homebrew not found. Installing...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "${GREEN}Homebrew found.${NC}"
    fi

    # Ensure Git is installed
    if ! which git >/dev/null; then
        echo "${YELLOW}Git not found. Installing...${NC}"
        brew install git
    else
        echo "${GREEN}Git found.${NC}"
    fi

    # Check macOS version and handle ZSH installation if needed
    version=$(sw_vers -productVersion)

    if [[ "$version" < "10.15" ]]; then
        echo "${YELLOW}macOS version is Catalina or older${NC}"
        echo "${YELLOW}Setting ZSH as default shell${NC}"
        brew install zsh
        chsh -s $(which zsh)
    else
        echo "${GREEN}macOS version is newer than Catalina${NC}"
    fi

    # Install Oh My Zsh if not already installed
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "${GREEN}Oh My Zsh already installed${NC}"
    else
        echo "${YELLOW}Installing Oh My Zsh${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" &
        wait
        if [ $? -eq 0 ]; then
            echo "${GREEN}Successfully installed Oh My Zsh${NC}"
        else
            echo "${RED}Error installing Oh My Zsh${NC}"
            exit 1
        fi
    fi

    if [ $? -eq 0 ]; then
        echo "${YELLOW}Installing Powerlevel10k${NC}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        sed -i '' 's#robbyrussell#powerlevel10k/powerlevel10k#g' ~/.zshrc
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' ~/.zshrc

        echo "${YELLOW}Installing plugins${NC}"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        sed -i '' 's/plugins=(git)/plugins=(git jump zsh-autosuggestions sublime zsh-history-substring-search jsontools zsh-syntax-highlighting zsh-interactive-cd)/g' ~/.zshrc
        echo "${GREEN}Please restart your terminal for changes to take effect${NC}"
    else
        echo "${RED}Error installing Oh My Zsh${NC}"
        exit 1
    fi

    # Interactive prompt for additional installations
    echo
    echo "${YELLOW}We will now install additional packages. Press 'y' to accept or 'n' to skip (No Enter needed):${NC}"

    # Function to read immediate input without pressing Enter
    get_immediate_input() {
        stty -icanon -echo
        response=$(dd bs=1 count=1 2>/dev/null)
        stty icanon echo
        echo "$response"
    }

    # Install Raycast
    echo -n "${YELLOW}Install Raycast? [Y/N]: ${NC}"
    install_raycast=$(get_immediate_input)
    if [ "$install_raycast" != "n" ] && [ "$install_raycast" != "N" ]; then
        echo "${YELLOW}Installing Raycast...${NC}"
        brew install raycast
    else
        echo "${GREEN}Skipping Raycast installation.${NC}"
    fi

    # Install iTerm2
    echo -n "${YELLOW}Install iTerm2? [Y/N]: ${NC}"
    install_iterm2=$(get_immediate_input)
    if [ "$install_iterm2" != "n" ] && [ "$install_iterm2" != "N" ]; then
        echo "${YELLOW}Installing iTerm2...${NC}"
        brew install --cask iterm2
    else
        echo "${GREEN}Skipping iTerm2 installation.${NC}"
    fi

    # Install fzf
    echo -n "${YELLOW}Install fzf? [Y/N]: ${NC}"
    install_fzf=$(get_immediate_input)
    if [ "$install_fzf" != "n" ] && [ "$install_fzf" != "N" ]; then
        echo "${YELLOW}Installing fzf...${NC}"
        brew install fzf
    else
        echo "${GREEN}Skipping fzf installation.${NC}"
    fi

    # Install VSCodium
    echo -n "${YELLOW}Install VSCodium? [Y/N]: ${NC}"
    install_vscodium=$(get_immediate_input)
    if [ "$install_vscodium" != "n" ] && [ "$install_vscodium" != "N" ]; then
        echo "${YELLOW}Installing VSCodium...${NC}"
        brew install --cask vscodium
    else
        echo "${GREEN}Skipping VSCodium installation.${NC}"
    fi

    # Install Firefox
    echo -n "${YELLOW}Install Firefox? [Y/N]: ${NC}"
    install_firefox=$(get_immediate_input)
    if [ "$install_firefox" != "n" ] && [ "$install_firefox" != "N" ]; then
        echo "${YELLOW}Installing Firefox...${NC}"
        brew install --cask firefox
    else
        echo "${GREEN}Skipping Firefox installation.${NC}"
    fi

    # Install GH
    echo -n "${YELLOW}Install GH? [Y/N]: ${NC}"
    install_gh=$(get_immediate_input)
    if [ "$install_gh" != "n" ] && [ "$install_gh" != "N" ]; then
        echo "${YELLOW}Installing GH...${NC}"
        brew install gh
    else
        echo "${GREEN}Skipping GH installation.${NC}"
    fi

    # Install Karabiner-Elements
    echo -n "${YELLOW}Install Karabiner-Elements? [Y/N]: ${NC}"
    install_karabiner=$(get_immediate_input)
    if [ "$install_karabiner" != "n" ] && [ "$install_karabiner" != "N" ]; then
        echo "${YELLOW}Installing Karabiner-Elements...${NC}"
        brew install --cask karabiner-elements
    else
        echo "${GREEN}Skipping Karabiner-Elements installation.${NC}"
    fi

    # Install Tailscale
    echo -n "${YELLOW}Install Tailscale? [Y/N]: ${NC}"
    install_tailscale=$(get_immediate_input)
    if [ "$install_tailscale" != "n" ] && [ "$install_tailscale" != "N" ]; then
        echo "${YELLOW}Installing Tailscale...${NC}"
        brew install tailscale
    else
        echo "${GREEN}Skipping Tailscale installation.${NC}"
    fi

    # Hide Dock instead of removing it
    echo -n "${YELLOW}Would you like to hide the macOS Dock? [Y/n]: ${NC}"
    hide_dock=$(get_immediate_input)

    if [ "$hide_dock" != "n" ] && [ "$install_gh" != "N" ]; then
        echo "${YELLOW}Hiding Dock...${NC}"
        defaults write com.apple.dock autohide -bool true; killall Dock
        echo "${GREEN}Dock is now hidden.${NC}"
    else
        echo "${GREEN}Dock will remain visible.${NC}"
    fi

    echo "${GREEN}Setup complete!${NC}"
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
