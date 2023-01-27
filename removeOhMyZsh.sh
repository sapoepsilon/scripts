#!/bin/sh -e

#Uninstall Oh My Zsh

uninstall_omz() {
    # Remove Oh My Zsh
    echo"removing Oh My Zsh folder..."

    rm -rf ~/.oh-my-zsh
    # Remove the custom theme
    rm ~/.zshrc
    echo"removing Oh My Zsh plugins..."
    # Remove any additional plugins
    rm -rf ~/.oh-my-zsh/custom/plugins
}

#Uninstall Zsh
uninstall_zsh() {
    # Remove Zsh
    sudo apt-get remove -y zsh
}

#Uninstall Powerlevel10k
uninstall_p10k() {
    # Remove powerlevel10k
    rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
}

#Run uninstall functions
uninstall_omz
uninstall_zsh
uninstall_p10k

echo "Oh My Zsh, Zsh, Powerlevel10k, and Plugins have been uninstalled."
