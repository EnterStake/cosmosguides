#
Commands to replace addrbook file in Quicksilver testnet
#

```sh
systemctl stop quicksilverd
rm /root/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://github.com/Firstcomes/all/blob/9a9fffcc04dd3d65935e3d3adc2041fc7854a636/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
