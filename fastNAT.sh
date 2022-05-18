#!/bin/bash

if [ -z "$2" ]
then
    echo "Usage: ./fastNAT.sh RULE_FILE INTERFACE"
    exit 1
fi

rule_file=$1
iface=$2

echo -e "\033[1mRunning fastNAT...\033[0m"
echo "Using rule file: $rule_file"
echo

if [ ! -f $rule_file ]
then
    echo "Error: Unable to find specified rule file."
    exit 1
fi

echo "Found rules:"
while IFS=, read -r src dst
do
    echo -e "\033[1;33m* $src <--> $dst\033[0m"
done < $rule_file
echo

read -p "Do you want to apply the above rules? (y/N)? " choice
case "$choice" in
  y|Y)
      echo "Applying rules..."
      ;;
  *)
      echo "Exiting..."
      exit 0
      ;;
esac
echo

echo "Enabling IPv4 forwarding..."
sysctl -w net.ipv4.ip_forward=1

echo "Clearing NAT table..."
iptables -t nat -F

echo "Setting up NAT rules..."
while IFS=, read -r src dst
do
    iptables -t nat -A PREROUTING -d $src -i $iface -j DNAT --to-destination $dst
    iptables -t nat -A POSTROUTING -s $dst -o $iface -j SNAT --to-source $src
done < $rule_file

echo "Saving NAT rules to /etc/iptables/rules.v4"
iptables-save -t nat > /etc/iptables/rules.v4

echo "Setting NAT MASQUERADE..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo
echo "Applied rules:"
echo

iptables -t nat -nL

echo
echo -e "\033[1mfastNAT complete.\033[0m"
