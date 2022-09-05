##
**Commands to replace addrbook file in Sei Network testnet**
##

```sh
systemctl stop seid
rm $HOME/.sei/config/addrbook.json 
wget -O $HOME/.sei/config/addrbook.json "https://raw.githubusercontent.com/EnterStake/cosmosguides/main/Testnets/Sei/addrbook.json"
systemctl restart seid && journalctl -u seid -f -o cat
```

