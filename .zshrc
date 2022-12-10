# Path to your oh-my-zsh installation.
export ZSH=/Users/rajin/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

# User configuration

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias vi="vim"
alias sudo="sudo "
alias rm="rm -i"
alias mv="mv -i"

code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# git
alias gs="git status"
function gcbd() {
  if [ -z $1 ]; then
    echo "empty argument is not supported"
    return -1
  fi
  local dateStr
  dateStr=$(date +'%y%m%d') &&
  git checkout -b david/$dateStr-$1
}
alias gd="git diff --color-moved"
alias gdc="git diff --cached --color-moved"
alias gp="git push -u origin"
function gbsu() {
  local branchName
  branchName=$(git symbolic-ref --short HEAD)
  git branch -u origin/$branchName
}

function gprune() {
  git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'); do git branch -D $branch; done
}
function gcr() {
  local branchName
  branchName=$(git branch -r | grep -e "origin/release-*" | fzf -1)
  branchName=$(echo -n "${branchName//[[:space:]]/}")
  branchName="${branchName:7}"
  git checkout $branchName
}

# github
alias ghpr="gh pr create -w"
function ghprq() {
  local branchName
  branchName=$(git branch -r | grep -e "origin/release-*" | fzf -1)
  branchName=$(echo -n "${branchName//[[:space:]]/}")
  branchName="${branchName:7}"
  gh pr create -w --base $branchName

setopt cdable_vars

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export TERM="xterm-256color"

alias gw="./gradlew"
alias deeplink="adb shell am start -a android.intent.action.VIEW -d"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# folder of all of your autocomplete functions
fpath=($HOME/.zsh-completions $fpath)
