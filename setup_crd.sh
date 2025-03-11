#!/bin/bash
set -e

# ===== Configuration Variables =====
USERNAME="user"
PASSWORD="root"
PIN="123456"
AUTOSTART="true"

# CRD command (no interactive input) with corrected quoting
CRD_COMMAND="/opt/google/chrome-remote-desktop/start-host --code=\"4/0AQSTgQG8Y56Z5Qfw3D9VpFE7RVY07sAFAdAlkhPGh6Mbhyy1DDUCQTo2u9Jdl_egmBzAGg\" --redirect-url=\"https://remotedesktop.google.com/_/oauthredirect\" --name=$(hostname) --pin=${PIN}"

# ===== Create a New User and Set Password =====
useradd -m ${USERNAME}
usermod -aG sudo ${USERNAME}
echo "${USERNAME}:${PASSWORD}" | chpasswd
sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

# ===== Update and Install Packages =====
apt update

install_crd() {
  wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
  dpkg --install chrome-remote-desktop_current_amd64.deb || apt install --assume-yes --fix-broken
  echo "Chrome Remote Desktop Installed!"
}

install_desktop_environment() {
  export DEBIAN_FRONTEND=noninteractive
  apt install --assume-yes xfce4 desktop-base xfce4-terminal
  echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session
  apt remove --assume-yes gnome-terminal
  apt install --assume-yes xscreensaver
  apt purge --assume-yes light-locker
  apt install --assume-yes --reinstall xfce4-screensaver
  systemctl disable lightdm.service || true
  echo "XFCE4 Desktop Environment Installed!"
}

install_google_chrome() {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg --install google-chrome-stable_current_amd64.deb || apt install --assume-yes --fix-broken
  echo "Google Chrome Installed!"
}

install_telegram() {
  apt install --assume-yes telegram-desktop
  echo "Telegram Installed!"
}

change_wallpaper() {
  curl -s -L -k -o xfce-verticals.png https://gitlab.com/chamod12/changewallpaper-win10/-/raw/main/CachedImage_1024_768_POS4.jpg
  cp "$(pwd)/xfce-verticals.png" /usr/share/backgrounds/xfce/
  echo "Wallpaper Changed!"
}

install_qbittorrent() {
  apt update
  apt install -y qbittorrent
  echo "Qbittorrent Installed!"
}

finish_setup() {
  if [ "$AUTOSTART" = "true" ]; then
    mkdir -p /home/${USERNAME}/.config/autostart
    cat <<EOF > /home/${USERNAME}/.config/autostart/colab.desktop
[Desktop Entry]
Type=Application
Name=Colab
Exec=sh -c "sensible-browser www.youtube.com/@The_Disala"
Icon=
Comment=Open a predefined notebook at session signin.
X-GNOME-Autostart-enabled=true
EOF
    chmod +x /home/${USERNAME}/.config/autostart/colab.desktop
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
  fi

  usermod -aG chrome-remote-desktop ${USERNAME}

  # Run the Chrome Remote Desktop command as the created user.
  su - ${USERNAME} -c "${CRD_COMMAND}"
  service chrome-remote-desktop start

  echo "Log in PIN : ${PIN}"
  echo "User Name : ${USERNAME}"
  echo "User Pass : ${PASSWORD}"
  
  # Keep the container running
  tail -f /dev/null
}

# ===== Execute All Steps =====
install_crd
install_desktop_environment
change_wallpaper
install_google_chrome
install_telegram
install_qbittorrent
finish_setup
