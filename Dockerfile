FROM centos:latest

MAINTAINER Abed Halawi <abed.halawi@vinelab.com>

# install openssh server
RUN yum -y install openssh-server

# install openssh clients
RUN yum -y install openssh-clients

# make ssh directories
RUN mkdir /root/.ssh
RUN mkdir /var/run/sshd

# create host keys
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_key
RUN ssh-keygen -b 1024 -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -b 1024 -t dsa -f /etc/ssh/ssh_host_dsa_key

# move public key to enable ssh keys login
ADD docker_ssh.pub /root/.ssh/authorized_keys
RUN chmod 400 /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys
# tell ssh to not use ugly PAM
RUN sed -i 's/UsePAM\syes/UsePAM no/' /etc/ssh/sshd_config

# make the terminal prettier
RUN echo 'export PS1="[\u@docker] \W # "' >> /root/.bash_profile

# enable networking
RUN echo 'NETWORKING=yes' >> /etc/sysconfig/network

EXPOSE 80
EXPOSE 22

ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["-D"]
