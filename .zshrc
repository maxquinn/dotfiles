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
alias vi='nvim'
alias vim='nvim'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias kill3k='kill -15 $(lsof -ti:3000)'
alias z='zellij -l welcome'
function zrun() {
  zellij run -i -- "$@"
}

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
bindkey '^[[1;3C' forward-word        # Option+Right
bindkey '^[[1;3D' backward-word       # Option+Left

# fnm
eval "$(fnm env --use-on-cd --version-file-strategy=recursive --shell zsh)"

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
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ZSH Auto Suggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Must be last
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fnm
FNM_PATH="/Users/$USER/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/$USER/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi

# bun completions
[ -s "/Users/max.quinn/.bun/_bun" ] && source "/Users/max.quinn/.bun/_bun"

export EDITOR=nvim
export VISUAL=nvim
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# dotnet
export DOTNET_ROOT=/usr/local/share/dotnet/x64
export PATH=$PATH:$DOTNET_ROOT

export PATH="$HOME/.local/bin:$PATH"
export NODE_EXTRA_CA_CERTS=~/corporate-certs.pem

export OPENAI_API_KEY=op://Checkout/OpenAI/credential
