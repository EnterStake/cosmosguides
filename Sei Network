#
Commands to replace addrbook file in Sei Network testnet
#

```sh
systemctl stop seid
rm $HOME/.sei-chain/config/addrbook.json 
wget -O $HOME/.sei-chain/config/addrbook.json "https://raw.githubusercontent.com/Firstcomes/manuals/main/Sei Network/addrbook.json"
systemctl restart seid && journalctl -u seid -f -o cat
```
