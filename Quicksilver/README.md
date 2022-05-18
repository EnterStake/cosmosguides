#
Commands to replace addrbook file in Quicksilver testnet
#

```sh
systemctl stop quicksilverd
rm $HOME/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://github.com/Firstcomes/manuals/blob/ccebfeda72a9e0e489e4c5b275157b3a657c0b46/Quicksilver/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
