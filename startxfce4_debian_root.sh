#!/data/data/com.termux/files/usr/bin/bash

pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce4-session" 2>/dev/null
rm -f $TMPDIR/.X0-lock $TMPDIR/.X11-unix/X0 2>/dev/null

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

mkdir -p $HOME/.runtime
chmod 700 $HOME/.runtime
export XDG_RUNTIME_DIR=$HOME/.runtime

termux-x11 :0 &

virgl_test_server_android &

for i in {1..10}; do [ -S "$TMPDIR/.X11-unix/X0" ] && break; sleep 0.5; done

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

export PULSE_SERVER=127.0.0.1
export DISPLAY=:0

# Start XFCE inside proot with proper session
proot-distro login debian --shared-tmp -- /bin/bash -c "export DISPLAY=:0; export XDG_RUNTIME_DIR=/run/user/$(id -u); export GALLIUM_DRIVER=virpipe; export MESA_GL_VERSION_OVERRIDE=4.0; dbus-launch --exit-with-session startxfce4;"
