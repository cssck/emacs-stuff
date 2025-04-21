# Honor per-interactive-shell startup file
if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
export LANG=en_US.utf-8
export PATH=$PATH:$HOME/.local/bin:$HOME/.bin:$HOME/.py/bin:/usr/lib/go-1.22/bin

if [ ! -f /.dockerenv ] && [ ! -f /run/.containerenv ] && [ -d "$HOME/.guix-profile" ]; then
    # source "$HOME/.guix-profile/etc/profile"
    # source "$HOME/.config/guix/current/etc/profile"
    export PATH="$PATH:$HOME/.guix-profile/bin"
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:$HOME/.guix-profile/share"
    export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
    # export GUIX_SANDBOX_EXTRA_SHARES="/mnt/media/aprilsnow/external/Steam"
fi

if [ "$HOSTNAME" = "normandy" ] && [ ! -f /run/.containerenv ]
then
    export LIBVA_DRIVER_NAME=iHD
    export LD_PRELOAD=/home/aprilsnow/.guix-profile/lib/dri/iHD_drv_video.so
    export MOZ_USE_XINPUT2=1
fi

if [[ "$(tty)" == "/dev/tty2" ]]
then
    export XDG_CURRENT_DESKTOP=sway
    exec dbus-run-session -- sway
fi
