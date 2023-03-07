<p align="center" width="100%">
    <img width="13%" src="https://pbs.twimg.com/profile_images/1603111084583358464/hQ4S0cA0_400x400.jpg"> 
</p>
 

## Install Ojo network node (ojo-devnet)
> Vps 4/8/200гб
> >Explorer https://ojo.explorers.guru/

1. ##### Install packages
```sh
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
2. ##### Install GO
```sh
wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz

cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile

#Check
go version
```
##### 3. Install
```sh
cd $HOME
git clone https://github.com/ojo-network/ojo.git
cd ojo
git checkout v0.1.2
make install

#Check
ojod version
```

##### 4.Init
```sh 
# change NODENAME to your validator name
ojod init NODENAME --chain-id ojo-devnet
```
##### 4. Genesis and gas price
```sh
curl -s https://rpc.devnet-n0.ojo-devnet.node.ojo.network/genesis | jq -r .result.genesis > $HOME/.ojo/config/genesis.json
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.000uojo\"/" $HOME/.ojo/config/app.toml
```
##### 5. Peers
```sh
peers="6f304029cb1b7fbcbe1359d57cbb69ae8dbcccfc@207.180.243.64:36656,5af3d50dcc231884f3d3da3e3caecb0deef1dc5b@142.132.134.112:25356,62fa77951a7c8f323c0499fff716cd86932d8996@65.108.199.36:24214,9edc978fd53c8718ef0cafe62ed8ae23b4603102@136.243.103.32:36656,ac5089a8789736e2bc3eee0bf79ca04e22202bef@162.55.80.116:29656,bd35cfd5bfbea4c2a63e893860d4f9a7d880957c@213.239.217.52:45656,408ee86160af26ee7204d220498e80638f7874f4@161.97.109.47:38656,c37e444f67af17545393ad16930cd68dc7e3fd08@95.216.7.169:61156,fbeb2b37fe139399d7513219e25afd9eb8f81f4f@65.21.170.3:38656,239caa37cb0f131b01be8151631b649dc700cd97@95.217.200.36:46656,e54b02d103f1fcf5189a86abe542670979d2029d@65.109.85.170:58656,9bcec17faba1b8f6583d37103f20bd9b968ac857@38.146.3.230:21656,1145755896d6a3e9df2f130cc2cbd223cdb206f0@209.145.53.163:29656,b0968b57bcb5e527230ef3cfa3f65d5f1e4647dd@35.212.224.95:26656,8671c2dbbfd918374292e2c760704414d853f5b7@35.215.121.109:26656,2691bb6b296b951400d871c8d0bd94a3a1cdbd52@65.109.93.152:33656,cbe534c7d012e9eb4e71a5573aee8acc1adf4bc6@65.108.41.172:28056,a23cc4cbb09108bc9af380083108262454539aeb@35.215.116.65:26656,3d11a6c7a5d4b3c5752be0c252c557ed4acc2c30@167.235.57.142:36656,b6b4a4c720c4b4a191f0c5583cc298b545c330df@65.109.28.219:21656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.ojo/config/config.toml
```

##### 6. Prunning
```sh
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.ojo/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.ojo/config/app.toml
```

##### 7. Create service
```sh 
tee /etc/systemd/system/ojod.service > /dev/null <<EOF
[Unit]
Description=ojod
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which ojod) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

#activate service and reboot
sudo systemctl daemon-reload
sudo systemctl enable ojod 
sudo systemctl restart ojod && sudo journalctl -u ojod -f
```

##### 8.Quick sync (Statesync)
```sh

sudo systemctl stop ojod
ojod tendermint unsafe-reset-all --home $HOME/.ojo --keep-addr-book 

STATE_SYNC_RPC="http://207.180.243.64:36657"

LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.ojo/config/config.toml
  
 #Reboot
sudo systemctl restart ojod && sudo journalctl -u ojod -f
```
##### 9. Wallet and validator #####

```sh
#Create wallet and save SEED PHRASE 
ojod keys add wallet

#Save also priv_validator_key.json
cat $HOME/.ojo/config/priv_validator_key.json

# Recover wallet
ojod keys add wallet --recover

#Create validator. NODENAME edit to your validator nme

ojod tx staking create-validator \
--amount=1000000uojo \
--pubkey=$(ojod tendermint show-validator) \
--moniker=NODENAME \
--chain-id=ojo-devnet \
--commission-rate=0.1 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.05 \
--min-self-delegation=1 \
--fees=10uojo \
--from=wallet

```
### Useful command

##### Addrbook #####
> if you have problem with peers

```sh
systemctl stop ojod
rm $HOME/.ojo/config/addrbook.json
wget -O $HOME/.ojo/config/addrbook.json "https://raw.githubusercontent.com/EnterStake/cosmosguides/main/Ojo/addrbook.json"
sudo systemctl restart ojod && sudo journalctl -u ojod -f
```

##### Turn off Statesync
```sh
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.ojo/config/config.toml
```
##### Check status
```sh
ojod status | jq
```
##### Unjail 
```sh 
ojod tx slashing unjail --from wallet --chain-id ojo-devnet --gas-prices 0.1uojo --gas-adjustment 1.5 --gas auto 
```
##### Edit validator
```sh
ojod tx staking edit-validator \
--identity xxxxxxxx \
--website="xxxxxxxxx" \
--details="xxxxxxxx" \
--commission-rate=0.1 \
--chain-id ojo-devnet \
--gas "auto" \
--from wallet \
--fees=10uojo
```
