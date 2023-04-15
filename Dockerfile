FROM debian:bullseye-slim

ENV VERSION v4.38-9760-rtm-2021.08.17
WORKDIR /usr/local/vpnbridge

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y -q --no-install-recommends install iptables gcc make wget gcc-multilib && \
    apt-get clean && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/* && \
    wget http://www.softether-download.com/files/softether/${VERSION}-tree/Linux/SoftEther_VPN_Bridge/64bit_-_Intel_x64_or_AMD64/softether-vpnbridge-${VERSION}-linux-x64-64bit.tar.gz -O /tmp/softether-vpnbridge.tar.gz &&\
    tar -xzvf /tmp/softether-vpnbridge.tar.gz -C /usr/local/ && \
    rm /tmp/softether-vpnbridge.tar.gz &&\
    make &&\
    apt-get purge -y -q --auto-remove gcc make wget gcc-multilib

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
