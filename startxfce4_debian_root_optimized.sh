#!/data/data/com.termux/files/usr/bin/bash

# Kill previous sessions
pkill -9 termux.x11 2>/dev/null
pkill -9 xfce4-session 2>/dev/null
pkill -9 virgl_test_server_android 2>/dev/null

# Clean old X11 sockets
rm -rf $TMPDIR/.X11-unix
rm -f $TMPDIR/.X0-lock
mkdir -p $TMPDIR/.X11-unix

# Runtime directory for host
mkdir -p $HOME/.runtime
chmod 700 $HOME/.runtime
export XDG_RUNTIME_DIR=$HOME/.runtime

# Start PulseAudio
pulseaudio --start \
 --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
 --exit-idle-time=-1

# Start GPU server
virgl_test_server_android &

# Start Termux X11
termux-x11 :0 &

# Wait until X server is ready
for i in {1..20}; do
  [ -S "$TMPDIR/.X11-unix/X0" ] && break
  sleep 0.3
done

# Open Android X11 window
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1

sleep 1

export DISPLAY=:0
export PULSE_SERVER=127.0.0.1

# Start Debian XFCE
proot-distro login debian --shared-tmp -- /bin/bash -c '

export DISPLAY=:0
export PULSE_SERVER=127.0.0.1

# Runtime directory inside proot
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

# GPU acceleration
export GALLIUM_DRIVER=virpipe
export MESA_GL_VERSION_OVERRIDE=4.0
export MESA_GLSL_VERSION_OVERRIDE=400

# Reduce XFCE warnings
export LIBGL_ALWAYS_SOFTWARE=0

# Start DBus session
dbus-daemon --session --fork --print-address

# Start XFCE
startxfce4
'


# ---Packages Required---
# ---In Termux---
# pkg install x11-repo
# pkg install termux-x11-nightly virglrenderer-android pulseaudio proot-distro

# ---Install archlinux---
# proot-distro install debian

# ---In ArchLinux (inside proot)---
# pkg update
# pkg install xfce4 xfce4-goodies dbus-x11 mesa-utils

# ---Test GPU Acceleration---
# ---Inside XFCE terminal run---
# glxinfo | grep OpenGL
# ---Expected---
# OpenGL renderer string: virgl

# ---Performance Tips
# ---Disable XFCE compositor (big FPS gain):---
# ---Settings -> Window Manager Tweaks -> Compositor -> Disable