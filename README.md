###Commands to replace addrbook file in Quicksilver testnet###

systemctl stop quicksilverd
rm $HOME/root/.quicksilverd/config/addrbook.json
wget -O $HOME/.quicksilverd/config/addrbook.json "https://github.com/Firstcomes/all/blob/26a4731681dece29d9be25fff3d68c75d31a801a/addrbook.json"
systemctl restart quicksilverd && journalctl -u quicksilverd -f -o cat
