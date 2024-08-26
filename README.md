# dotfiles
initial dev setting

# initial setting

* keyboard language
* Fn functions

# initial tools

* brew
* iterm2
    * use Solarized-dark
    * Hotkey : shift+cmd+k
* vim
* vim-plug
* fzf
* lazygit
* github cli 

# settings

symbolic links

```
ln -s ~/dotfiles/.gitignore_global ~/
ln -s ~/dotfiles/.gitconfig ~/
ln -s ~/dotfiles/.vimrc ~/
ln -s ~/dotfiles/.ideavimrc ~/
ln -s ~/dotfiles/lazygit.config.yml ~/Library/Application\ Support/lazygit/config.yml

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -sf ~/dotfiles/.tmux.conf ~

# zsh
git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
ln -sf ~/dotfiles/.zshrc ~
cp ~/dotfiles/.zshrc.local ~
exec zsh
p10k configure
```

