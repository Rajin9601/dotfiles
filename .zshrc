# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1
zinit light romkatv/powerlevel10k
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-completions

# zsh-autosuggestions
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#767676"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

autoload -Uz compinit bashcompinit
compinit
bashcompinit
zinit cdreplay

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

PROMPT='$(kube_ps1)'$PROMPT

unalias zi
eval "$(zoxide init zsh)"

# Load local configs
if [[ -f ~/.zshrc.local ]]; then
  source ~/.zshrc.local
fi

# ETCs

alias vi="vim"
alias rm="rm -i"
alias mv="mv -i"
alias cp='cp -i'
alias ..='cd ../'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
if (( $+commands[lsd] )); then
  alias l='lsd -Al'
  alias ll='lsd -l'
  alias lt='lsd --tree --depth=2'
else
  alias l='ls -alh'
  alias ll='ls -lh'
fi

HISTSIZE=90000
SAVEHIST=90000
HISTFILE=~/.zsh_history

setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

export EDITOR=vim

# vscode

code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# git
source ~/dotfiles/git.plugin.zsh
alias gs="git status"
function gcbd() {
  if [ -z $1 ]; then
    echo "empty argument is not supported"
    return -1
  fi
  local dateStr
  dateStr=$(date +'%y%m%d') &&
  git checkout -b rajin/$dateStr-$1
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
}

# fzf

fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

fbro() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

fzf-all() {
  fzf --height 100% "$@" --border
}

gfSCR() {
  git -c color.status=always status --short |
  fzf-all -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d) | head -500' --preview-window right:50%:wrap|
  cut -c4- | sed 's/.* -> //'
}

# lazygit

lg()
{
    export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir

    lazygit "$@"

    if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
            cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
            rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
    fi
}

setopt cdable_vars

# export TERM="xterm-256color"

alias gw="./gradlew"
alias deeplink="adb shell am start -a android.intent.action.VIEW -d"
alias sourceZ="source ~/.zshrc"

# infra

## kubectl
source <(kubectl completion zsh)

alias k="kubectl"
# alias kctx="kubectx"
# alias kns="kubens"
alias kctx="switch"
alias kns="switch namespace"
alias k9="k9s --readonly"

# terraform
alias tf="terraform"

# zsh vi-mode backspace problem
bindkey "^?" backward-delete-char

source <(switcher init zsh)
source <(switcher completion zsh)

. /opt/homebrew/opt/asdf/libexec/asdf.sh
