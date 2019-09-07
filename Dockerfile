FROM centos:7
MAINTAINER "Michael A. Ventarola" <mikev1963@me.com>
ENV container docker

# Install systemd -- See https://hub.docker.com/_/centos/
RUN yum -y update; yum clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install requirements.
RUN yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      sudo \
      redhat-lsb \
      openssh-server \
      which \
      rsyslog \
      bind-utils \
      net-tools \
      python-pip \
      filesystem \
 && yum clean all

# Following fixes follwoing issue for standard users:
# System is booting up. See pam_nologin(8) 
RUN systemctl enable systemd-user-sessions.service && ln -s /usr/lib/systemd/system/systemd-user-sessions.service /etc/systemd/system/default.target.wants/systemd-user-sessions.service

# Remove unnecessary getty and udev targets that can result in high CPU usage when using
# multiple containers with Molecule (https://github.com/ansible/molecule/issues/1104)
RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

# SSH login fix. Otherwise user is kicked off after login
RUN mkdir /var/run/sshd
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install local users in container
COPY useradd.sh /
RUN chmod +x /useradd.sh && /useradd.sh

EXPOSE 22
RUN systemctl enable sshd

VOLUME /run /tmp

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/lib/systemd/systemd"]
