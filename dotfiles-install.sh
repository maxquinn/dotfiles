git clone --bare git@github.com:maxquinn/dotfiles.git "$HOME"/.cfg
function config {
  /usr/bin/git --git-dir="$HOME"/.cfg/ --work-tree="$HOME" "$@"
}
mkdir -p .config-backup

if config checkout = 0; then
  echo "Checked out config."
else
  echo "Backing up pre-existing dot files."
  config checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi
config checkout
config config status.showUntrackedFiles no
