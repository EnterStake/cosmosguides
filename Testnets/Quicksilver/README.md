#
Quicksilver v0.6.3 v0.6.6-hotfix Upgrade (innuendo1)
# 
A countdown clock is [here](https://quicksilver.explorers.guru/block/226627)
```sh
sudo systemctl stop quicksilverd

cd $HOME
rm quicksilver -rf
git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.6.6-hotfix
cd quicksilver
make build   #if doesnt work then use make install
sudo chmod +x ./build/quicksilverd && sudo mv ./build/quicksilverd /usr/local/bin/quicksilverd

#Check version
quicksilverd version
#should be v0.6.6-hotfix

sudo systemctl restart quicksilverd && sudo journalctl -u quicksilverd -f -o cat
```




#
Commands to replace addrbook file in Quicksilver testnet (innuendo1)
# 

```sh
systemctl stop quicksilverd
rm $HOME/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://raw.githubusercontent.com/EnterStake/cosmosguides/main/Testnets/Quicksilver/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
```
 
