exec swayidle -w \
	timeout 240 'gtklock -d -b ~/.config/nixos/wallpapers/wawa.png -i' \
	before-sleep 'gtklock -d -b ~/.config/nixos/wallpapers/wawa.png -i'