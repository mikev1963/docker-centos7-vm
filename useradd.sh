#!/bin/sh

USER_LIST="ansible mikev1963"
SUDO_GROUP=wheel

OSTYPE="`lsb_release -d |awk '{print $2}'`"
echo $OSTYPE

case "${OSTYPE}" in
  *Ubuntu* )
     echo "Ubuntu" 
     SUDO_GROUP=sudo
     ;;
  *CentOS* )
     echo "Centos" 
     SUDO_GROUP=wheel
     ;;
  *)
     echo "error"
     exit 1
     ;;
esac

# Set root password
echo "root:toor" | chpasswd

# Create local accounts for all users in USER_LIST
for user in ${USER_LIST};
do
        echo ${user}
        groupadd -r ${user}
        useradd -m -g ${user} ${user}
        usermod -aG ${SUDO_GROUP} ${user}
        sed -i "/%${SUDO_GROUP}.*NOPASSWD/s/^#\s*//g" /etc/sudoers
        echo "${user}:${user}" | chpasswd
done

