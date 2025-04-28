FROM fedora:41

ENV container=docker

# Ignore weak dependencies
RUN echo "install_weak_deps=false" >> /etc/dnf/dnf.conf

# Install required packages in a single step
RUN dnf -y update && \
    dnf -y install git python3 python3-virtualenv openssl \
                   top ps btop ncdu iproute-tc iputils

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
    find / -type d -name '*cache*' -o -type f \( -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf {} + 2>/dev/null && \
    rm -rf /root/.config/systemd

VOLUME ["/sys/fs/cgroup"]
ENTRYPOINT ["source", "~/.rpi-web-shell/venv/bin/activate && python", "~/.rpi-web-shell/shell_server.py"]
