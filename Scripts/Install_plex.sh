#!/bin/bash
sudo apt update
sudo apt install -y xserver-xorg xinit xserver-xorg-input-all
sudo apt install -y autoconf make automake build-essential gperf yasm gnutls-dev libv4l-dev checkinstall libtool libtool-bin libharfbuzz-dev libfreetype6-dev libfontconfig1-dev libx11-dev libcec-dev libxrandr-dev libvdpau-dev libva-dev mesa-common-dev libegl1-mesa-dev yasm libasound2-dev libpulse-dev libbluray-dev libdvdread-dev libcdio-paranoia-dev libsmbclient-dev libcdio-cdda-dev libjpeg-dev libluajit-5.1-dev libuchardet-dev zlib1g-dev libfribidi-dev git libgnutls28-dev libgl1-mesa-dev libgles2-mesa-dev libsdl2-dev cmake python3 python python-minimal git

#### Compile MPV (plex video player)###
git clone https://github.com/mpv-player/mpv-build.git
cd mpv-build

echo --extra-ldflags="-latomic" >> ffmpeg_options
echo --enable-libmpv-shared > mpv_options
echo --disable-cplayer >> mpv_options

./use-mpv-release
./use-ffmpeg-release

./rebuild -j$(nproc)

sudo ./install
sudo ldconfig

### Install OpenGL Drivers Needed####
cd /home/pi/
wget https://github.com/koendv/qt5-opengl-raspberrypi/releases/download/v5.12.5-1/qt5-opengl-dev_5.12.5_armhf.deb
sudo apt-get install -y ./qt5-opengl-dev_5.12.5_armhf.deb
rm qt5-opengl-dev_5.12.5_armhf.deb

### Compile Plex Media Player (front end) ###
cd /home/pi/
git clone https://github.com/plexinc/plex-media-player
mkdir /home/pi/plex-media-player/build
cd /home/pi/plex-media-player/build
cmake -DCMAKE_BUILD_TYPE=Debug -DQTROOT=/usr/lib/qt5.12/ -DCMAKE_INSTALL_PREFIX=/usr/local/ ..
make -j$(nproc)
sudo make install

### Making Plex Accessable via RetroPie ###
cd /home/pi/
mkdir -p /home/pi/RetroPie/roms/plex

### make .sh to launch plex ###
echo '#!/bin/bash
export DISPLAY=:0.0
export XDG_SESSION_TYPE=x11
export XAUTHORITY=/home/pi/.Xauthority
/usr/local/bin/plexmediaplayer --fullscreen --tv
' > /home/pi/RetroPie/roms/plex/launch_plex.sh

sudo chmod a+x /home/pi/RetroPie/roms/plex/launch_plex.sh
sudo chown -R pi:pi /home/pi/RetroPie/roms/plex

### Make Plex Accessable via Gamepad  ###
mkdir -p /home/pi/.local/share/plexmediaplayer/inputmaps/
echo '{
  "name": "Xbox Controller",
  "idmatcher": "SteelSeries Stratus*",
  "mapping":
  {
    // A
    "KEY_BUTTON_0": "enter",

    // B
    "KEY_BUTTON_1": {
      "short": "back",
      "long": "home"
    },

    // X
    "KEY_BUTTON_2": "cycle_audio",

    // Y
    "KEY_BUTTON_3": "cycle_subtitle",
    "KEY_BUTTON_3": "search",

    // LB
    "KEY_BUTTON_4": "seek_backward",

    // RB
    "KEY_BUTTON_5": "seek_forward",

    // left thumbstick press
    "KEY_BUTTON_6": "host:toggleDebug",

    // right thumbstick press
    //"KEY_BUTTON_7": "host:fullscreen",

    // start
    "KEY_BUTTON_8": {
      "short": "home",
      "long": "exit"
    },

    // back
    "KEY_BUTTON_9": "",

    // D-PAD
    "KEY_BUTTON_11": "up",
    "KEY_BUTTON_12": "down",
    "KEY_BUTTON_13": "left",
    "KEY_BUTTON_14": "right",

    // left thumbstick axis
    "KEY_AXIS_0_UP": "left",
    "KEY_AXIS_0_DOWN": "right",
    "KEY_AXIS_1_UP": "up",
    "KEY_AXIS_1_DOWN": "down",

    // right thumbstick axis
    "KEY_AXIS_4_UP": "increase_volume",
    "KEY_AXIS_4_DOWN": "decrease_volume",

    // D-Pad with JoyHat events
    "KEY_HAT_DOWN": "down",
    "KEY_HAT_UP": "up",
    "KEY_HAT_RIGHT": "right",
    "KEY_HAT_LEFT": "left"

  }
}
' > /home/pi/.local/share/plexmediaplayer/inputmaps/xbox-controller-windows.json

sudo chown -R pi:pi /home/pi/.local/share/plexmediaplayer

### Installing Plex Theme to Carbon ###
echo -e "\nInstalling Plex Theme For Carbon"
sudo /bin/cp -r /home/pi/retromoonlight/themes/carbon/plex /etc/emulationstation/themes/carbon/

