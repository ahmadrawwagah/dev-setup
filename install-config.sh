echo "Installing Alacritty Config"
cp ./.alacritty.toml ~/
echo "Installing Nvim and Tmux Config"
mkdir -p ~/.config/nvim
cp ./.tmux.conf ~/
cp ./init.lua ~/.config/nvim/
rm -rf ~/.config/tmux/plugins
mkdir -p ~/.config/tmux/plugins/
echo "Installing Tmux Plugins"
git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/
git clone https://github.com/tmux-plugins/tmux-cpu ~/.config/tmux/plugins/tmux-cpu
git clone https://github.com/tmux-plugins/tmux-battery ~/.config/tmux/plugins/tmux-battery

echo "Need to install clangd, pylsp, lualsp, fzf, bat, ripgrep, the_silver_searcher, perl, universal-ctags"
