# Setup fzf
# ---------
if [[ ! "$PATH" == */usr/local/opt/fzf/bin* ]]; then
  export PATH="$PATH:/usr/local/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/usr/local/opt/fzf/shell/key-bindings.zsh"

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

# fuzzy multi-select modified file
gfmod() {
  local modified untracked
  modified=$(git ls-files -m) &&
  untracked=$(git ls-files --others --exclude-standard) &&
  echo "$modified\n$untracked" | fzf -m
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

fga() {
  git add $(gfSCR)
}

#fstash
fstash() {
  local stash
  stash=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
      fzf-all -m --ansi \
      --preview 'echo {-1}' --preview-window right:50%:wrap) &&
  echo "$stash"
}

fstash2() {
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    IFS=$'\n'; set -f
    lines=($(<<< "$out"))
    unset IFS; set +f
    q="${lines[0]}"
    k="${lines[1]}"
    sha="${lines[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git -c color.ui=always stash show -p $sha | less -+F
    fi
  done
}
