#!/bin/bash

# Default Values
HOMEDIR=$(ls -d ~)
APPDIR=$HOMEDIR/Openframe-WebApp

#----------------------------------------------------------------------------
 function get_webapp_config {
#----------------------------------------------------------------------------
# Get the information needed to configure the web app server
  echo -e "\n***** Collecting configuration information"

  ### Get API server URL
  URLPAT='(^https?://[-A-Za-z0-9]+\.[-A-Za-z0-9\.]+(:[0-9]+)?$)|(^$)'

  [ -r $APPDIR/.env ] && API_BASE=$(cat "$APPDIR/.env" | cut -d"=" -f2 | cut -d"/" -f1-3)
  [ -z "$API_BASE" ] || [ "$API_BASE" == "null" ] && API_BASE="https://api.openframe.io"
  while [ 1 ]; do
    read -p "URL to be used for API server ($API_BASE)? " NAPI_BASE
    [[ ! "$NAPI_BASE" =~ $URLPAT ]] && continue
    [ ! -z "$NAPI_BASE" ] && API_BASE=$NAPI_BASE
    break
  done

  ### Ask for Autoboot
  while [ 1 ]; do
    read -p "Do you want to autostart the Openframe Web Server when booting (Y/n): " AUTOBOOT
    [[ ! "$AUTOBOOT" =~ (^[Yy][Ee]?[Ss]?$)|(^[Nn][Oo]?$)|(^$) ]] && continue
    [ -z $AUTOBOOT ] && AUTOBOOT="Y"
    break
  done

  if [[ $AUTOBOOT =~ ^[Yy] ]]; then
    AUTOBOOT="true"
  else
    AUTOBOOT="false"
  fi
} # get_webapp_config

#----------------------------------------------------------------------------
 function install_nodejs {
#----------------------------------------------------------------------------
# Check if nodejs is already installed and install the current LTS release
# if this is not the case
  echo -e "\n***** Installing nodejs and npm"
  NPMVERS=$(npm --version 2>/dev/null)
  NODEVERS=$(node --version 2>/dev/null)

  if [ $? -gt 0 ] || [[ ! "$NODEVERS" =~ ^v1[4-9].*$ ]]; then
    curl -fsSL https://deb.nodesource.com/setup_14.x | sudo bash -
    sudo apt install -y nodejs
  else
    echo nodejs $NODEVERS and npm v$NPMVERS are already installed
  fi
} # install_install_nodejs

#----------------------------------------------------------------------------
 function install_dpackage {
#----------------------------------------------------------------------------
# Check if a specific Debian package is installed already and install it
# if this is not the case
  local DPACKAGE=$1

  echo -e "\n***** Installing $DPACKAGE"
  dpkg -s $DPACKAGE > /dev/null 2>&1;
  if [ $? -gt 0 ]; then
    sudo apt update && sudo apt install -y $DPACKAGE
  else
    echo $DPACKAGE is already installed
  fi
} # install_dpackage

#----------------------------------------------------------------------------
 function install_webapp {
#----------------------------------------------------------------------------
# Install the WebApp repository
  echo -e "\n***** Installing Openframe WebApp"
  cd $HOMEDIR/
  git clone --depth=1 --branch=master https://github.com/mataebi/Openframe-WebApp.git
  cd Openframe-WebApp
  npm install
  npm audit fix
} # install_webapp

#----------------------------------------------------------------------------
 function install_config {
#----------------------------------------------------------------------------
# Make sure the webapp configuration is initialized if needed
  echo -e "\n***** Installing initial configuration"
  echo "API_HOST=$API_BASE/v0/" > "$APPDIR/.env"
  sed -i "s|^ *apiBase: .*,$|  apiBase: '$API_BASE/v0/',|" $HOMEDIR/Openframe-WebApp/src/config/dev.js
  sed -i "s|^ *apiBase: .*,$|  apiBase: '$API_BASE/v0/',|" $HOMEDIR/Openframe-WebApp/src/config/dist.js
} # install_config

#----------------------------------------------------------------------------
 function install_service {
#----------------------------------------------------------------------------
# Make sure the web app service is properly installed
  echo -e "\n***** Installing web app service"

  echo "Installing service at /lib/systemd/system/of-webapp.service"
  local SERVICE_FILE=/usr/lib/systemd/system/of-webapp.service
  sudo cp -p $HOMEDIR/Openframe-WebApp/scripts/of-webapp.service $SERVICE_FILE
  sudo sed -i "s|<user>|$(id -un)|g" $SERVICE_FILE
  sudo sed -i "s|<appdir>|$HOMEDIR/Openframe-WebApp|g" $SERVICE_FILE
  sudo systemctl daemon-reload

  if [ $AUTOBOOT == "true" ]; then
    echo "Enabling autostart of service"
    sudo systemctl enable of-webapp.service
  else
    echo "Disabling autostart of service"
    sudo systemctl disable of-webapp.service
  fi
  sudo systemctl enable systemd-networkd-wait-online.service
} # install_service

#----------------------------------------------------------------------------
# main
#----------------------------------------------------------------------------
  install_dpackage curl
  install_nodejs
  install_dpackage phantomjs
  export QT_QPA_PLATFORM=offscreen
  install_dpackage git

  get_webapp_config
  install_webapp
  install_config
  install_service
