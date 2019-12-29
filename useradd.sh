#!/bin/sh

USER_LIST="ansible"
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
        mkdir -p /home/${user}/.ssh
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCk8J1hk7fnHFQ+IJBiBafYlps9z/j4oNbxChWZzCZ80ZB6p6r/6XORHIbb90Kh6d/+meMXVuMNrRQSbDyxoEAS7RarDuADYm2DhOxdxueecwnvBR2+NdGBeixxDjldWvPNa5/mto3CWA77mc9qdYj42s2fY8p8RvtPCNM6ShfPiCUXQrHydUZIdqqmltsElZ5gqKlI7DbGdWFJcxM1+aeaY78rmw+WZyDeMeEtER7ko2v5vqg44QdIKKyOHW/KaLZjYyGJFHz+LsbcSl4ED1Ds9f9Fp+M4a79GVNfOnw8FM1UGJDqhYW6XG/zzkOhb2gOgKcZPC1mQLyxAEe1GJ7TP mikev1963@Michaels-MBP.fios-router.home" >> /home/${user}/.ssh/authorized_keys
done

