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
ln -s ~/dotfiles/.alacritty.toml ~/
ln -s ~/dotfiles/.tmux.conf ~

ln -s ~/dotfiles/lazygit.config.yml ~/Library/Application\ Support/lazygit/config.yml
ln -s ~/dotfiles/.ghostty.conf ~/.config/ghostty/config

# neovim (AstroNvim). set up mise first (mason needs node, python, ...)
ln -s ~/dotfiles/nvim ~/.config/nvim
nvim # then run :Lazy restore

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# zsh
git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
ln -sf ~/dotfiles/.zshrc ~
ln -s ~/dotfiles/.p10k.zsh ~/
exec zsh
p10k configure
```

