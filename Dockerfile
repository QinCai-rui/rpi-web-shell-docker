FROM fedora:41

ENV container=docker

# Ignore weak dependencies
RUN echo "install_weak_deps=false" >> /etc/dnf/dnf.conf

# Install required packages in a single step
RUN dnf -y update && \
    dnf -y install systemd dbus dbus-daemon git python3 python3-virtualenv openssl \
                   top ps btop ncdu iproute-tc iputils

# Clean unused systemd components in one efficient command
RUN find /lib/systemd/system/sysinit.target.wants/ -mindepth 1 ! -name 'systemd-tmpfiles-setup.service' -delete && \
    rm -rf /lib/systemd/system/multi-user.target.wants/* /etc/systemd/system/*.wants/* \
           /lib/systemd/system/local-fs.target.wants/* /lib/systemd/system/sockets.target.wants/*udev* \
           /lib/systemd/system/sockets.target.wants/*initctl* /lib/systemd/system/basic.target.wants/* \
           /lib/systemd/system/anaconda.target.wants/*

# Create necessary directories
RUN mkdir -p /run/systemd/system /run/dbus

# Set proper stop signal
STOPSIGNAL SIGRTMIN+3

# Install RPi Web Shell
RUN curl -sSL https://raw.githubusercontent.com/QinCai-rui/rpi-web-shell/refs/heads/main/universal-installer.bash -O && \
    chmod +x universal-installer.bash && \
    bash universal-installer.bash --api=${SHELL_API_KEY:-random-api-key} --port=5001 --method=1 --assume-yes && \
    rm universal-installer.bash

RUN dnf -y remove openssl git vim-minimal && \
    dnf clean all

# Modify permissions and remove unnecessary files
RUN chmod u+w /root /usr/bin /usr/lib /usr/lib64 /usr/sbin && \
    find / -type d -name '*cache*' -o -type f \( -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf {} + 2>/dev/null

# Configure systemd service
RUN cp ~/.config/systemd/user/rpi-shell.service /etc/systemd/system/ && \
    rm -rf /root/.config/systemd && \
    mkdir -p /etc/systemd/system/default.target.wants && \
    ln -s /etc/systemd/system/rpi-shell.service /etc/systemd/system/default.target.wants/rpi-shell.service

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["/sbin/init"]
