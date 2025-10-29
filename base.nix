{ config, pkgs, self, ... }:

{
  home.stateVersion = "25.11";
 
  home.packages = with pkgs; [
    stow
    fzf
    bat
    eza
    fd
    git
    delta
    jq
    micro
    oh-my-zsh
    zsh-powerlevel10k
    zsh-syntax-highlighting
    zsh-autocomplete
    zsh-autosuggestions
    zsh-fzf-tab  
  ];
}
