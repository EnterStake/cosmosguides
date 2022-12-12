


#
Commands to replace addrbook file in Quicksilver testnet (innuendo4)
# 

```sh
systemctl stop quicksilverd
rm $HOME/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://raw.githubusercontent.com/EnterStake/cosmosguides/main/Testnets/Quicksilver/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
 
 
