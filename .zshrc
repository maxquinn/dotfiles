# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r '${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh' ]]; then
  source '${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh'
fi

# Configure aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias npmcu='npx npm-check-updates -u'
alias npmcuh='rm -rf node_modules package-lock.json && npx npm-check-updates -u && npm i'
alias limmy='open -a chatterino && streamlink -p /Applications/IINA.app/Contents/MacOS/IINA https://www.twitch.tv/limmy 480p'
alias vi='nvim'
alias vim='nvim'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Configure git aliases
function __git_prompt_git() {
  GIT_OPTIONAL_LOCKS=0 command git "$@"
}

function git_current_branch() {
  local ref
  ref=$(__git_prompt_git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(__git_prompt_git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

alias gst='git status'
alias gaa='git add --all'
alias gfe='git fetch'
alias gd='git diff'
alias gco='git checkout'
alias gcmsg='git commit --message'
alias gcb='git checkout -b'
alias ggp='git push origin "$(git_current_branch)"'
alias ggl='git pull origin "$(git_current_branch)"'
alias glog='git log --oneline --decorate --graph'
alias glogg='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'

# Configure autocomplete
autoload -Uz compinit
compinit
zstyle ':completion:*:*:*:*:*' menu select
bindkey '^[[Z' reverse-menu-complete  # shift+tab

# Setup NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/maxquinn/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/maxquinn/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/maxquinn/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/maxquinn/google-cloud-sdk/completion.zsh.inc'; fi

# Setup fzf and key bindings
source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Configure Powerlevel10k
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ZSH Auto Suggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Must be last
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
