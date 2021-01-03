#!/bin/bash

#vm 생
#https://docs.microsoft.com/ko-kr/azure/virtual-machines/linux/quick-create-cli

#사용 가능한 location 체크
az account list-locations -o table

#resource group 생성 
# vm 의 배포될 지역과 관리 집합 지.
az group create -l canadacentral -n siwoo-rg1

# vm 생성 & ssh key 등
az vm create -g siwoo-rg1 \
  -n siwoo-vm1 \
  --image UbuntuLTS \
  --admin-username azureuser \
  --authentication-type ssh \
  --ssh-key-value ~/.ssh/id_rsa.pub
  
# port 오픈. (inbounding port)
az vm open-port -g siwoo-rg1 -n siwoo-vm1 --port 22

# public 아이피 주소 확인
az vm list-ip-addresses -n siwoo-vm1 -o table

# ssh 로 접근
ssh azureuser@아이피