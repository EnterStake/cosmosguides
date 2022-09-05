#!/bin/bash
for((;;)); do
height=$(quicksilverd status --node http://0.0.0.0:26657  |& jq -r  ."SyncInfo"."latest_block_height")
if ((height>=226627)); then
        cd $HOME
        sudo systemctl stop quicksilverd
        rm quicksilver -rf
        git clone https://github.com/ingenuity-build/quicksilver.git --branch v0.6.6-hotfix
        cd quicksilver
        make build
        sudo chmod +x ./build/quicksilverd && sudo mv ./build/quicksilverd /usr/local/bin/quicksilverd
        sudo systemctl restart quicksilverd
        echo "restart the system..."
        sudo systemctl restart quicksilverd
          for (( timer=60; timer>0; timer-- ))
          do
                printf "* second restart after sleep for \e[31m%02d\e[39m sec\r" $timer
                sleep 1
          done
         sudo systemctl restart quicksilverd
    height=$(quicksilverd status --node http://0.0.0.0:26657  |& jq -r  ."SyncInfo"."latest_block_height")
           if ((height>=226628)); then
           echo -e "\e[32mUPDATE SUCCESSFULL - ... CHECK VERSION\e[39m\n"
    quicksilverd version --long | head
          else
          echo "Check LOGS..."
          fi
        break
  else
  echo $height
  fi
sleep 3
done
