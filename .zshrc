# These lines should be applied to local .zshrc
#
# ZSH_THEME="robbyrussell"


# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

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

export TERM="xterm-256color"

alias gw="./gradlew"
alias deeplink="adb shell am start -a android.intent.action.VIEW -d"
