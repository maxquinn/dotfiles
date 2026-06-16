
# Ignore ctrl+d EOF signal
setopt IGNORE_EOF
# Vim bindings
bindkey -v
# Cursor shape based on vi mode
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[1 q'  # Block cursor (normal mode)
  else
    echo -ne '\e[5 q'  # Bar cursor (insert mode)
  fi
}

function zle-line-init {
  echo -ne '\e[5 q'  # Bar cursor on new prompt
}

zle -N zle-keymap-select
zle -N zle-line-init

# Configure aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias npmcu='npx npm-check-updates -u'
alias npmcuh='rm -rf node_modules package-lock.json && npx npm-check-updates -u && npm i'
alias vi='nvim'
alias vim='nvim'
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias kill3k='kill -15 $(lsof -ti:3000)'
alias ta="tmux attach -t"
alias tl="tmux ls"

# Hunk PR review helper
# hpr [PR] opens a GitHub PR diff in Hunk. With no PR, gh uses the current branch PR.
# This uses Hunk's native git loader instead of piping a patch, so in-app navigation works better.
function hpr() {
  local pr_arg="${1:-}"
  local pr_view_args=()

  if [[ -n "$pr_arg" && "$pr_arg" != "--" ]]; then
    pr_view_args=("$pr_arg")
    shift
  fi

  local pr_number base_ref head_ref base_remote_ref
  pr_number=$(gh pr view "${pr_view_args[@]}" --json number -q .number) || return $?
  base_ref=$(gh pr view "$pr_number" --json baseRefName -q .baseRefName) || return $?

  head_ref="refs/remotes/origin/pr/$pr_number"
  base_remote_ref="refs/remotes/origin/$base_ref"

  echo "Fetching PR #$pr_number..."
  git fetch -q origin \
    "refs/heads/$base_ref:$base_remote_ref" \
    "refs/pull/$pr_number/head:$head_ref" || return $?

  hunk diff "$base_remote_ref...$head_ref" "$@"
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

# Setup fzf and key bindings
source <(fzf --zsh)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Starship prompt
eval "$(starship init zsh)"

# ZSH Auto Suggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Must be last
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


# bun completions
[ -s "/Users/$USER/.bun/_bun" ] && source "/Users/$USER/.bun/_bun"

export EDITOR=nvim
export VISUAL=nvim
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export CLAUDE_CODE_TMUX_TRUECOLOR=1

# dotnet
export DOTNET_ROOT=/usr/local/share/dotnet/x64
export PATH=$PATH:$DOTNET_ROOT

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/scripts:$PATH"
[ -f ~/corporate-certs.pem ] && export NODE_EXTRA_CA_CERTS=~/corporate-certs.pem

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/max.quinn/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/max.quinn/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/max.quinn/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/max.quinn/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Pi
export PATH="/Users/max.quinn/.local/share/fnm/node-versions/v22.13.1/installation/bin:$PATH"
