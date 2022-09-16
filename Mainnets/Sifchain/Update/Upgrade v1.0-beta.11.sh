#!/bin/bash
for((;;)); do
height=$(sifnoded status --node http://0.0.0.0:26657  |& jq -r  ."SyncInfo"."latest_block_height")
if ((height>=8618770)); then
        cd sifnoded
        sudo systemctl stop cosmovisord
        git pull
        git checkout v1.0-beta.11
        make install
        sifnoded version
        mkdir -p /root/.sifnoded/cosmovisor/upgrades/1.0-beta.11/bin
        cp $HOME/go/bin/sifnoded /root/.sifnoded/cosmovisor/upgrades/1.0-beta.11/bin
        $HOME/.sifnoded/cosmovisor/upgrades/1.0-beta.11/bin/sifnoded version
        sudo systemctl restart cosmovisord
        echo "restart the system..."
        sudo systemctl restart cosmovisord
          for (( timer=60; timer>0; timer-- ))
          do
                printf "* second restart after sleep for \e[31m%02d\e[39m sec\r" $timer
                sleep 1
          done
         sudo systemctl restart cosmovisord
    height=$(sifnoded status --node http://0.0.0.0:26657  |& jq -r  ."SyncInfo"."latest_block_height")
           if ((height>=8618771)); then
           echo -e "\e[32mUPDATE SUCCESSFULL - ... CHECK VERSION\e[39m\n"
    sifnoded version --long | head
          else
          echo "Check LOGS..."
          fi
        break
  else
  echo $height
  fi
sleep 3
done
