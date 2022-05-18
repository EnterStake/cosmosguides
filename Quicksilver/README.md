#
Commands to replace addrbook file in Quicksilver testnet
#

```sh
systemctl stop quicksilverd
rm /root/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://github.com/Firstcomes/manuals/blob/16733767d2884a7c64eb2da4edcca65b4c966711/Quicksilver/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
