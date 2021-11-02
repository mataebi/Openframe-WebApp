#!/bin/bash
# Do a complete Openframe-WebApp de-installation. Ask for each step
# unless the "-y" flag was passed

NOASK=$1

#----------------------------------------------------------------------------
 function ask {
#----------------------------------------------------------------------------
# Ask a yes or no question and set $ANSWER accordingly. Default answer is N
  if [ "$NOASK" == "-y" ]; then
    ANSWER="Y"
  else
    QUESTION=$1
    while [ 1 ]; do
      echo
      read -p "$QUESTION (y/N): " ANSWER
      [[ ! "$ANSWER" =~ (^[Yy][Ee]?[Ss]?$)|(^[Nn][Oo]?$)|(^$) ]] && continue
      [ -z $ANSWER ] && ANSWER="N"
      break
    done
    ANSWER=$(echo $ANSWER | cut -c1 | tr yn YN)
  fi
} # ask

#----------------------------------------------------------------------------
# main
#----------------------------------------------------------------------------
  cd ~/

  ask "Do you want to remove the Openframe-WebApp software?"
  if [ "$ANSWER" == "Y" ]; then
    echo "***** Removing Openframe-WebApp"
    rm -rf ~/Openframe-WebApp
  fi

  ask "Do you want to remove nodejs?"
  if [ "$ANSWER" == "Y" ]; then
    echo "***** Removing nodejs and npm"
    sudo apt remove -y nodejs npm
  fi

  ask "Do you want to remove the npm cache of user $(id -un)?"
  if [ "$ANSWER" == "Y" ]; then
    echo "***** Removing npm cache"
    rm -rf ~/.npm
  fi

  ask "Do you want to remove and disable the web service?"
  if [ "$ANSWER" == "Y" ]; then
    echo "***** Removing and stopping web service"
    sudo rm -rf oframe-webapp
    sudo a2dissite $(grep -l oframe-webapp /etc/apache2/sites-enabled/* |rev | cut -d'/' -f1 | rev)
    sudo service apache2 restart
  fi
