# Start from Amazon Linux base image
FROM amazonlinux:2023

ARG CHROMIUM_SHA

# Set environment variables
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV PATH "$PATH:/srv/source/depot_tools"
ENV CHROMIUM_SHA=${CHROMIUM_SHA}

# Update the system and install packages
RUN yum update -y && \
    yum groupinstall -y "Development Tools" && \
    yum install -y alsa-lib-devel atk-devel bc bluez-libs-devel bzip2-devel cairo-devel cmake cups-devel \
                   dbus-devel dbus-glib-devel dbus-x11 expat-devel glibc glibc-langpack-en gperf gtk3-devel \
                   httpd java-17-amazon-corretto libatomic libcap-devel libjpeg-devel libstdc++ libXScrnSaver-devel \
                   libxkbcommon-x11-devel mod_ssl ncurses-compat-libs nspr-devel nss-devel pam-devel \
                   pciutils-devel perl php php-cli pulseaudio-libs-devel python python-psutil python-setuptools \
                   ruby xorg-x11-server-Xvfb zlib \
                   python3 python3-pip

# Create Directory Structure
RUN mkdir -p /srv/build/chromium /srv/source/chromium

# Clone Depot Tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /srv/source/depot_tools
ENV PATH "$PATH:/srv/source/depot_tools"

# Copy .gclient file
COPY .gclient /srv/source/chromium/.gclient
# Copy the args; these will have to be moved into the correct place by the chromium builder
COPY args.gn /srv/source/chromium/args.gn

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
