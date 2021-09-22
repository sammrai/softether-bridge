#!/bin/bash

if [ ! -d "/var/log/vpnbridge/security_log" ]; then
  mkdir -p /var/log/vpnbridge/security_log
fi

if [ ! -d "/var/log/vpnbridge/packet_log" ]; then
  mkdir -p /var/log/vpnbridge/packet_log
fi

if [ ! -d "/var/log/vpnbridge/server_log" ]; then
  mkdir -p /var/log/vpnbridge/server_log
fi

/usr/local/vpnbridge/vpnbridge start

vpncmd_hub () {
  /usr/local/vpnbridge/vpncmd localhost /SERVER /CSV /ADMINHUB:BRIDGE /CMD "$@"
}

# wait until server comes up
while : ; do
  set +e
  vpncmd_hub statusget
  [[ $? -eq 0 ]] && break
  set -e
  sleep 1
done

# setting up vpn bridge
vpncmd_hub  ExtOptionSet DisableKernelModeSecureNAT /VALUE:1
vpncmd_hub  ExtOptionSet DisableIpRawModeSecureNAT /VALUE:1
vpncmd_hub  SecureNatEnable
vpncmd_hub  CascadeCreate mycascade /SERVER:${VPN_SERVER} /HUB:DEFAULT /USERNAME:${USERNAME}
vpncmd_hub  CascadePasswordSet mycascade /PASSWORD:${PASSWORD} /TYPE:standard
vpncmd_hub  CascadeOnline mycascade
vpncmd_hub  Cascadelist

tail -F /usr/local/vpnbridge/*_log/*.log &

set +e
while pgrep vpnbridge > /dev/null; do sleep 1; done
set -e
