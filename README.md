# fastNAT

Easily turn your Debian Linux server into a NAT relay using iptables. Supports reading from an input CSV to specify orignal destination and NAT destination IP addresses.

## Usage

Before running, ensure that the NAT machine on which you are running fastNAT is reachable at each of the original IP addresses. Then, ensure that the NAT machine can reach each of the new destination IP addresses.

Specify the addresses you would like to be translated in a rule CSV such as [example_rules.csv](example_rules.csv). The first and second columns contain address pairs that will be used to create NAT rules forwarding from the first column address to the second column address.

Then, run the following:
```
./fastNAT RULE_FILE INTERFACE
```

For example:
```
./fastNAT myrules.csv eth0
```

The required iptables entries will be added to the NAT table and printed out for the user to review.

*Warning: This won't work around any restrictions of iptables. The NAT translation will only work properly for machines outside of the NAT machine itself.*

## Persistent iptables

To make iptables rules added by fastNAT persistent across reboot, install `iptables-persistent`, e.g.:

```
sudo apt install -y iptables-persistent
```
