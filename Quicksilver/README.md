#
Commands to replace addrbook file in Quicksilver testnet
#

```sh
systemctl stop quicksilverd
rm $HOME/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://raw.githubusercontent.com/Firstcomes/manuals/main/Quicksilver/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
