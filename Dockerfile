FROM fedora:41

ENV container=docker

##################################
# REPLACE WITH YOUR OWN API KEY!!

ENV SHELL_API_KEY=random-api-key

##################################

# Ignore weak dependencies
#RUN sed -i '/^ \
#
#\[main\] \
#
#$/a install_weak_deps=false' /etc/dnf/dnf.conf

RUN echo "install_weak_deps=false" >> /etc/dnf/dnf.conf

# Install systemd and necessary packages
RUN dnf -y update
RUN dnf -y install systemd dbus dbus-daemon systemd-container && \
    dnf clean all

# Clean unused systemd components
RUN (cd /lib/systemd/system/sysinit.target.wants/ ; for i in * ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i ; done) && \
    rm -f /lib/systemd/system/multi-user.target.wants/* && \
    rm -f /etc/systemd/system/*.wants/* && \
    rm -f /lib/systemd/system/local-fs.target.wants/* && \
    rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
    rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
    rm -f /lib/systemd/system/basic.target.wants/* && \
    rm -f /lib/systemd/system/anaconda.target.wants/*

# Create necessary directories
RUN mkdir -p /run/systemd/system && \
    mkdir -p /run/dbus && \
    mkdir -p /etc/systemd/system.conf.d

# Create empty files for next step (otherwise `sh` will complain)
RUN touch /etc/systemd/system.conf.d/00-container.conf 

# Configure systemd for container environment
RUN echo "[Manager]" > /etc/systemd/system.conf.d/00-container.conf && \
    echo "DefaultDependencies=no" >> /etc/systemd/system.conf.d/00-container.conf && \
    echo "DefaultLimitNOFILE=65536" >> /etc/systemd/system.conf.d/00-container.conf && \
    echo "JoinControllers=cpu,cpuacct,cpuset,net_cls,net_prio,hugetlb,memory,devices,pids,blkio,freezer" >> /etc/systemd/system.conf.d/00-container.conf

# Set proper stop signal
STOPSIGNAL SIGRTMIN+3

# Install RPi Web Shell
RUN dnf -y install git python3 python3-virtualenv openssl
RUN curl -sSL https://raw.githubusercontent.com/QinCai-rui/rpi-web-shell/refs/heads/main/universal-installer.bash -O && \
    chmod +x universal-installer.bash && \
    bash universal-installer.bash --api=$SHELL_API_KEY --port=5001 --method=1 --assume-yes

RUN rm universal-installer.bash

# Modify some things to suit the container
RUN chmod u+w /root /usr/bin /usr/lib /usr/lib64 /usr/sbin
RUN find / -type d -name '*cache*' -o -type f \( -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf {} + 2>/dev/null
RUN cp ~/.config/systemd/user/rpi-shell.service /etc/systemd/system/ && \
    rm -r /root/.config/systemd
RUN dnf -y remove openssl git vim-minimal && \
    dnf -y install git-core top ps btop ncdu iproute-tc iputils && \
    dnf clean all   
RUN mkdir -p /etc/systemd/system/default.target.wants && \
    ln -s /etc/systemd/system/rpi-shell.service /etc/systemd/system/default.target.wants/rpi-shell.service

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/sbin/init"]
