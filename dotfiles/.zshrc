#COLORTERM=truecolor may cause issues in erlier versions of windows terminal (prior to windows10 RS2)
export COLORTERM=truecolor
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -U fpath
(){
local profile
for profile in ${(z)NIX_PROFILES}; do
  fpath+=(
    $profile/share/zsh/site-functions
    $profile/share/zsh/$ZSH_VERSION/functions
    $profile/share/zsh/vendor-completions
  )
done
}

export ZSH="$HOME/.nix-profile/share/oh-my-zsh"
autoload -U compinit; compinit # had to run before the fzf tab plugin
source $HOME/.nix-profile/share/fzf-tab/fzf-tab.plugin.zsh
source $HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh

plugins=(git fzf dirhistory eza)
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes
_fzf_dir_preview="eza --almost-all --group-directories-first --tree --level=1 --icons=always --color=always {} | head --lines 200"
_file_preview="if [ -d {} ]; then $_fzf_dir_preview; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$_file_preview'"
export FZF_ALT_C_OPTS="--preview '$_fzf_dir_preview'"
export EDITOR="micro"
export VISUAL="code"

source $ZSH/oh-my-zsh.sh


_redraw_prompt() {
  local precmd
  for precmd in "${precmd_functions[@]}"; do
    [[ -n $precmd ]] && "$precmd"
  done
  zle reset-prompt
  zle redisplay
}

# Function: fzf child dir cd
fzf_cd_child() {
  local dir dirs ec

  # Build list: normal dirs first, then dot dirs, sorted separately
    dirs=$(
    {
      find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
        | grep -v '^\.' \
        | sort

      find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
        | grep '^\.' \
        | sort \
        | sed $'s/.*/\033[2m&\033[0m/'
    }
  )

  # Exit if no dirs found
  [[ -z $dirs ]] && return 1

   dir=$(echo "$dirs" | fzf --ansi --height=50% --reverse  --select-1 --cycle --preview "$_fzf_dir_preview")

  ec=$?

  _redraw_prompt

  # Normalize exit codes (1 = no match, 130 = ESC/CTRL-C)
  if [[ $ec -eq 1 || $ec -eq 130 ]]; then
    return 0
  elif [[ $ec -ne 0 ]]; then
    return $ec
  fi

  # Strip ANSI codes before cd
  dir=$(echo -E "$dir" | sed $'s/\033\\[[0-9;]*m//g')

  # Perform cd if something was chosen
  [[ -n $dir ]] && builtin cd "$dir" && _redraw_prompt

  return 0
}

# Register as a ZLE widget
zle -N fzf_cd_child

# Bind Alt+Down (all common sequences)
bindkey "^[^[OB"     fzf_cd_child
bindkey "^[^[[B"     fzf_cd_child
bindkey "^[O3B"      fzf_cd_child
bindkey "^[[1;3B"    fzf_cd_child
bindkey "^[[3B"      fzf_cd_child

bindkey "^z" undo
bindkey "^y" redo #override the "yank" widget


source $HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
