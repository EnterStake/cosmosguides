
<p align="center" width="100%">
    <img width="13%" src="https://pbs.twimg.com/profile_images/1532538144817434625/UknhHKpu_400x400.jpg"> 
</p>
 

## Установка ноды Andromeda (galileo-3) , а также полезные команды 
> Сервер 4/8/200гб
> >Explorer https://andromeda.explorers.guru/

1. ##### Подготовка
```sh
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
```
2. ##### Установка GO
```sh
wget https://go.dev/dl/go1.20.1.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.20.1.linux-amd64.tar.gz

#Одной командой
cat <<EOF >> ~/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source ~/.profile

#Проверяем
go version
```
##### 3. Установка 
```sh
cd $HOME
git clone https://github.com/andromedaprotocol/andromedad.git
cd andromedad
git checkout galileo-3-v1.1.0-beta1
make install

#Проверяем 
andromedad version
```

##### 4. Инициализируем ноду 
```sh 
# NODENAME меняем на название вашей ноды
andromedad init NODENAME --chain-id galileo-3
```
##### 4. Скачиваем генезиз и устанавливаем мин цену на газ
```sh
wget -qO $HOME/.andromedad/config/genesis.json "https://raw.githubusercontent.com/andromedaprotocol/testnets/galileo-3/genesis.json"
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0001uandr\"/" $HOME/.andromedad/config/app.toml
```
##### 5. Peers
```sh
PEERS="cd529600bb3aa20795a18c384c0edae2eb2da614@161.97.148.146:60656,dff203d0633c98eea4a228c5e913f22236043d89@23.88.69.101:16656,3f9594221efe3e9cd4d0de31f71993fc0f12bf01@65.21.245.252:26656,95e8225c5b8a21c1fecd411f37c75f5515de1891@185.197.251.203:26656,5e5186020063f7f8a3f3c6c23feca32830a18f33@65.109.174.30:56656,d30a56dd61de5b3e8d36bf40cb0a15add3915c91@195.3.223.33:37656,7ff2aaa5c49a0907e52689cc90fa416ec70e06a4@185.245.182.152:30656,704e605f9bd65912d8c65a58f955601c31188548@65.21.203.204:19656,433cc64756cb7f00b5fb4b26de97dc0db72b27ca@65.108.216.219:6656,b594f01b5b49a11b6d2e97c3b6358dc1388a1039@65.108.108.52:26656,29a9c5bfb54343d25c89d7119fade8b18201c503@209.34.206.32:26656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.andromedad/config/config.toml
```

##### 6. Приннинг (одной командой)
```sh
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.andromedad/config/app.toml
```

##### 7. Создаем сервис
```sh 
tee /etc/systemd/system/andromedad.service > /dev/null <<EOF
[Unit]
Description=andromedad
After=network.target
[Service]
Type=simple
User=$USER
ExecStart=$(which andromedad) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

#активируем сервис и делаем reboot
sudo systemctl daemon-reload
sudo systemctl enable andromedad 
sudo systemctl restart andromedad && sudo journalctl -u andromedad -f
```

##### 8. Быстрая синхронизация с помощью Statesync
```sh

sudo systemctl stop andromedad
andromedad tendermint unsafe-reset-all --home $HOME/.andromedad --keep-addr-book 

STATE_SYNC_RPC="http://161.97.148.146:60657"

LATEST_HEIGHT=$(curl -s $STATE_SYNC_RPC/block | jq -r .result.block.header.height)
SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
SYNC_BLOCK_HASH=$(curl -s "$STATE_SYNC_RPC/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)

sed -i \
  -e "s|^enable *=.*|enable = true|" \
  -e "s|^rpc_servers *=.*|rpc_servers = \"$STATE_SYNC_RPC,$STATE_SYNC_RPC\"|" \
  -e "s|^trust_height *=.*|trust_height = $SYNC_BLOCK_HEIGHT|" \
  -e "s|^trust_hash *=.*|trust_hash = \"$SYNC_BLOCK_HASH\"|" \
  -e "s|^persistent_peers *=.*|persistent_peers = \"$STATE_SYNC_PEER\"|" \
  $HOME/.andromedad/config/config.toml
  
 #Перезагрузка
sudo systemctl restart andromedad && sudo journalctl -u andromedad -f
```
##### 9. Кошелек и валидатор #####

```sh
#Создаем кошелек и сохраняем SEED PHRASE 
andromedad keys add wallet

#Также сохраняем priv_validator_key.json
cat $HOME/.andromedad/config/priv_validator_key.json

# Восстанавливаем кошелек (только, если уже создавали)
andromedad keys add wallet --recover

#После полной синхронизации создаем валидатора. NODENAME меняем на название вашей ноды

andromedad tx staking create-validator \
--amount=1000000uandr \
--pubkey=$(andromedad tendermint show-validator) \
--moniker=NODENAME \
--chain-id=galileo-3 \
--commission-rate=0.1 \
--commission-max-rate=0.2 \
--commission-max-change-rate=0.05 \
--min-self-delegation=1 \
--fees=10000uandr \
--from=wallet

```
### Полезные команды

##### Addrbook #####
> если есть проблемы с пирами

```sh
systemctl stop andromedad
rm $HOME/.andromedad/config/addrbook.json
wget -O $HOME/.andromedad/config/addrbook.json "https://raw.githubusercontent.com/EnterStake/cosmosguides/main/Andromeda/addrbook.json" 
sudo systemctl restart andromedad && sudo journalctl -u andromedad -f
```

##### Выкл Statesync
```sh
sed -i.bak -E "s|^(enable[[:space:]]+=[[:space:]]+).*$|\1false|" $HOME/.andromedad/config/config.toml
```
##### Проверяем статус
```sh
andromedad status | jq
```
##### Unjail 
```sh 
andromedad tx slashing unjail --from wallet --chain-id galileo-3 --gas-prices 0.1uandr --gas-adjustment 1.5 --gas auto 
```
##### Редактируем данные валидатора
```sh
andromedad tx staking edit-validator \
--identity xxxxxxxx \
--website="xxxxxxxxx" \
--details="xxxxxxxx" \
--commission-rate=0.1 \
--chain-id galileo-3 \
--gas "auto" \
--from wallet \
--fees=10000uandr
```
##### Voting
```sh
andromedad tx gov vote 1 yes --from wallet --chain-id galileo-3 --gas-prices 0.1uandr --gas-adjustment 1.5 --gas auto
```
