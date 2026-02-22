# Download all dependieces from: https://chatgpt.com/c/69222663-12e0-832f-86f6-844ebb0e498a
sudo pacman -S vlc
sudo pacman -S ffmpeg
# chrome pdf viwer is enough
# sudo pacman -S evince
#  nvim $(fzf) open searched file in nvim
sudo pacman -S fzf # exist in nvim(use it)
sudo pacman -S vlc
sudo pacman -S glow
sudo pacman -S mousepad
sudo pacman -S ristretto
sudo pacman -S ripgrep
sudo pacman -S cppcheck
yay -S simplex-chat-bin
yay -S discord   # turn animation off
sudo pacman -Syu # for update discord
sudo pacman -S man-db
sudo pacman -S man-pages
sudo pacman -S zsh
sudo pacman -S zsh-completions zsh-syntax-highlighting zsh-autosuggestions
sudo pacman -S bat
sudo pacman -S zoxide
sudo pacman -S xclip
sudo pacman -S eza
sudo pacman -S starship

# battery low warnings
sudo pacman -S libnotify upower dunst
systemctl --user daemon-reload
systemctl --user enable --now battery-notify.timer

sudo pacman -S xournalpp

sudo pacman -S yt-dlp
sudo pacman -S ffmpeg

sudo pacman -S rclone
sudo pacman -S xorg-xev
sudo pacman -S xdotool
