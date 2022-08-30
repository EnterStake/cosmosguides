#
Commands to replace addrbook file in Quicksilver testnet (innuendo1)
# 

```sh
systemctl stop quicksilverd
rm $HOME/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://raw.githubusercontent.com/Firstcomes/Cosmos-manuals/main/Quicksilver/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
 
