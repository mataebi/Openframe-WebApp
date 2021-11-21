#!/bin/bash
#
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
  DOMAINNAME=$(echo $API_BASE | rev | cut -d'.' -f1-2 | rev)

  ### Ask for Autoboot
  while [ 1 ]; do
    read -p "Do you want to autostart the Openframe Web Server when booting (Y/n): " AUTOBOOT
    AUTOBOOT=$(echo $AUTOBOOT | tr [A-Z] [a-z])
    [[ ! "$AUTOBOOT" =~ (^ye?s?$)|(^no?$)|(^$) ]] && continue
    [ -z $AUTOBOOT ] && AUTOBOOT="y"
    break
  done

  if [[ $AUTOBOOT =~ ^y ]]; then
    AUTOBOOT="true"
  else
    AUTOBOOT="false"
  fi

  ### Ask for server name & domain
  FULLNAME="openframe.$DOMAINNAME"
  while [ 1 ]; do
    read -p "Full Openframe Web App server name ($FULLNAME): " NFULLNAME
    [[ ! "$NFULLNAME" =~ (^[-a-z0-9]+\.[-a-z0-9]+\.[-a-z0-9\.]+$)|(^$) ]] && continue
    [ ! -z "$NFULLNAME" ] && FULLNAME=$NFULLNAME
    DOMAINNAME=$(echo $FULLNAME | rev | cut -d'.' -f1-2 | rev)
    SERVERNAME=$(echo $FULLNAME | rev | cut -d'.' -f3- | rev)
    break
  done

  ### Ask for http mode
  while [ 1 ]; do
    read -p "Do you want to use https / ssl (Y/n): " HTTPS
    HTTPS=$(echo $HTTPS | tr [A-Z] [a-z])
    [[ ! "$HTTPS" =~ (^ye?s?$)|(^no?$)|(^$) ]] && continue
    [ -z $HTTPS ] && HTTPS="y"
    break
  done

  if [[ $HTTPS =~ ^y ]]; then
    HTTPS="true"
    PORTNUM=443
    SRCFILE=webapp.example.com-ssl.conf

    # Ask for the SSL certificate path
    CERTPATH=/etc/ssl/certs/$FULLNAME.crt
    while [ 1 ]; do
      read -p "Where can the SSL certificate be found ($CERTPATH): " NCERTPATH
      [ ! -z $NCERTPATH ] && CERTPATH=$NCERTPATH
      break
    done

    # Ask for the SSL private key path
    KEYPATH=/etc/ssl/private/$FULLNAME.key
    while [ 1 ]; do
      read -p "Where can the SSL private key be found ($KEYPATH): " NKEYPATH
      [ ! -z $NKEYPATH ] && KEYPATH=$NKEYPATH
      break
    done
  else
    HTTPS="false"
    PORTNUM=8080
    SRCFILE=webapp.example.com-plain.conf
  fi

  ### Ask for port number
  while [ 1 ]; do
    read -p "Which port number should be used ($PORTNUM): " NPORTNUM
    [[ ! "$NPORTNUM" =~ (^[0-9]+$)|(^$) ]] && continue
    [ ! -z $NPORTNUM ] && PORTNUM=$NPORTNUM
    break
  done
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
} # install_nodejs

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
 function clone_webapp {
#----------------------------------------------------------------------------
# Clone the WebApp repository
  echo -e "\n***** Cloning Openframe WebApp"
  cd $HOMEDIR/
  git clone --depth=1 --branch=master https://github.com/mataebi/Openframe-WebApp.git
} # clone_webapp

#----------------------------------------------------------------------------
 function install_config {
#----------------------------------------------------------------------------
# Make sure the webapp configuration is initialized if needed
  echo -e "\n***** Installing initial configuration"
  echo "Updating $APPDIR/.env"
  echo "API_HOST=$API_BASE/v0/" > "$APPDIR/.env"
} # install_config

#----------------------------------------------------------------------------
 function build_webapp {
#----------------------------------------------------------------------------
# Build the productive version of the WebApp
  echo -e "\n***** Installing Openframe WebApp"
  cd $APPDIR
  npm install
  npm audit fix
  npm run dist
} # build_webapp

#----------------------------------------------------------------------------
 function install_webapp {
#----------------------------------------------------------------------------
# Install productive version of the WebApp and the websever config
  [ -d /var/www/oframe-webapp ] && sudo rm -rf /var/www/oframe-webapp
  [ -d $HOMEDIR/Openframe-WebApp/dist ] && sudo mv $HOMEDIR/Openframe-WebApp/dist /var/www/oframe-webapp

  DSTFILE=/etc/apache2/sites-available/$FULLNAME.conf
  sudo cp -p $HOMEDIR/Openframe-WebApp/setup/$SRCFILE $DSTFILE
  if [ $HTTPS == "true" ]; then
    sudo sed -i "s|<certpath>|$CERTPATH|g" $DSTFILE
    sudo sed -i "s|<keypath>|$KEYPATH|g" $DSTFILE
  else
    SRCFILE=webapp.example.com-plain.conf
  fi

  # Adjust the apache config file
  sudo sed -i "s|<port>|$PORTNR|g" $DSTFILE
  sudo sed -i "s|<fullname>|$FULLNAME|g" $DSTFILE

  [ ! -r /etc/apache2/sites-enabled/$FULLNAME.conf ] && sudo /usr/sbin/a2ensite $FULLNAME.conf
  sudo a2enmod ssl
  sudo service apache2 restart
} # install_webapp

#----------------------------------------------------------------------------
# main
#----------------------------------------------------------------------------
  get_webapp_config

  install_dpackage curl
  install_dpackage apache2
  install_nodejs
  install_dpackage phantomjs
  export QT_QPA_PLATFORM=offscreen
  install_dpackage git

  clone_webapp
  install_config
  build_webapp
  install_webapp
