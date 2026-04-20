#!/data/data/com.termux/files/usr/bin/bash

# Kill open X11 processes
kill -9 $(pgrep -f "termux.x11") 2>/dev/null

# Enable PulseAudio over Network
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# Prepare termux-x11 session
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null &

# Wait a bit until termux-x11 gets started.
sleep 3

# Launch Termux X11 main activity
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# Login in PRoot Environment. Do some initialization for PulseAudio, /tmp directory
# and run XFCE4 as user droidmaster.
# See also: https://github.com/termux/proot-distro
# Argument -- acts as terminator of proot-distro login options processing.
# All arguments behind it would not be treated as options of PRoot Distro.

#from droidmaster script

#proot-distro login ubuntu --shared-tmp -- /bin/bash -c  'export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=${TMPDIR} && su - ichigopres -c "env DISPLAY=:0 startxfce4"'

#my script
#proot-distro login ubuntu --shared-tmp -- /bin/bash -c  'export PULSE_SERVER=127.0.0.1 && export XDG_RUNTIME_DIR=${TMPDIR} && su - ichigopres -c "env DISPLAY=:0 dbus-launch --exit-with-session"'


#from chatgpt
#1 attempt

#proot-distro login ubuntu --shared-tmp -- bash -c 'su - ichigopres -c "export DISPLAY=:0; export PULSE_SERVER=127.0.0.1; export XDG_RUNTIME_DIR=/tmp/runtime-\$USER; mkdir -p \$XDG_RUNTIME_DIR; dbus-launch --exit-with-session startxfce4"'

#2 attempt

#proot-distro login ubuntu --shared-tmp -- bash -c '
#su - ichigopres -c "
#export DISPLAY=:0
#export PULSE_SERVER=127.0.0.1
#export XDG_RUNTIME_DIR=/tmp/runtime-\$USER
#mkdir -p \$XDG_RUNTIME_DIR
#chmod 700 \$XDG_RUNTIME_DIR
#dbus-launch --exit-with-session startxfce4
#"'

#3 attempt

#proot-distro login ubuntu --shared-tmp -- bash -c '
#su - ichigopres -c "
#export DISPLAY=:0
#export PULSE_SERVER=127.0.0.1
#export XDG_RUNTIME_DIR=/tmp/runtime/$USER
#mkdir -p $XDG_RUNTIME_DIR
#chmod 700 $XDG_RUNTIME_DIR
#dbus-launch --exit-with-session xfce4-session --display=:0 --disable-tcp
#"'


proot-distro login ubuntu --shared-tmp -- bash -c '
su - ichigopres -c "
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR=/tmp/runtime/$USER
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
dbus-launch --exit-with-session xfce4-session --display=:0 --disable-tcp
"'


exit 0
