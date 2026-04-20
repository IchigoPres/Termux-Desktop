#!/data/data/com.termux/files/usr/bin/bash

pkill -9 -f "termux.x11" 2>/dev/null
rm -f $TMPDIR/.X0-lock $TMPDIR/.X11-unix/X0 2>/dev/null

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

mkdir -p $HOME/.runtime
chmod 700 $HOME/.runtime
export XDG_RUNTIME_DIR=$HOME/.runtime

termux-x11 :0 &
X11_PID=$!

# Wait until X server actually creates the socket
for i in {1..10}; do
    [ -S "$TMPDIR/.X11-unix/X0" ] && break
    sleep 0.5
done

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

export PULSE_SERVER=127.0.0.1
export DISPLAY=:0

# Check if termux-x11 is still alive
if ! kill -0 $X11_PID 2>/dev/null; then
    echo "termux-x11 died. Check 'logcat | grep termux' for reason"
    exit 1
fi

exec env DISPLAY=:0 dbus-launch --exit-with-session xfce4-session
