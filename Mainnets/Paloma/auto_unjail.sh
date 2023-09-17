#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
PASWD='your_password'
DELAY=100 #Delay time in seconds
ACC_NAME=your key
NODE=http://localhost:26657
CHAIN=messenger
PROJECT=palomad
TOKEN_NAME=ugrain
for (( ;; )); do
        JAIL=$(${PROJECT} q staking validator $( echo "${PASWD}" | ${PROJECT} keys show ${ACC_NAME} --bech val -a) | grep jailed:);        
        if [[ ${JAIL} == *"false"* ]]; then
            echo -e "${GREEN}${JAIL} \n"
        else
            echo -e "${GREEN}${JAIL} \n"
            echo -e $( echo "${PASWD}" | ${PROJECT} tx slashing unjail --chain-id ${CHAIN} --from ${ACC_NAME} --gas-prices 0.1ugrain --gas-adjustment 1.5 --gas auto -y) \n;
            sleep 1
        fi
        for (( timer=${DELAY}; timer>0; timer-- ))
        do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
done
