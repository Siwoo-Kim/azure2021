#!/bin/bash
# creating & running docker container

#1. create docker image
#2. push the image into ACR (azure container registry)
#3. ACI (azure container instance) pull the image and create the container from that.

# build image from Dockerfile (Dummy app)
docker build -t azure2021:0.0.1 ~/workspace/azure2021/

# ACR 생성
#az acr create -g siwoo-rg1 -n siwooacr --sku Standard

# ACR 로그인
az acr login -n siwooacr

# 서버 호스트네임 로컬 변수에 저장
acr_server=$(az acr show -n siwooacr -g siwoo-rg1 --query loginServer --output tsv)

#docker image 을 ACR 로 푸쉬
docker tag azure2021:0.0.1 $acr_server/azure2021:0.0.1
docker push $acr_server/azure2021:0.0.1

#다른 방법으로 이미지 빌드 & push
az acr build --image azure2021:0.0.1-task --registry siwooacr ~/workspace/azure2021

#ACR 의 레파지토리 목록
az acr repository list -n siwooacr -o table

#ACR 의 특정 레파지토리의 모든 이미지 목
az acr repository show-tags -n siwooacr --repository azure2021 -o table

#ACR 리소스 id 로컬 변수에 저장
acr_registry_id=$(az acr show --name siwooacr --query id --output tsv)

#ACI 생성 파트. 중요 부분 (authentication & roles)
# authentication 방법 2 가지.
# 1. service principal
# 2. admin user (비추천) - portal -> acr -> access keys -> enable admin user

# ACR roles
#https://docs.microsoft.com/en-us/azure/container-registry/container-registry-roles

#service principal 생성  (active directory 와 service principal 권한이 필요함)

# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-service-principal
# https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
sp_name=acr-service-principal
sp_pwd=$(az ad sp create-for-rbac --name http://siwooacr-pull --scopes $acr_registry_id --role acrpull --query password -o tsv)
sp_appid=$(az ad sp show --id http://siwooacr-pull --query appId -o tsv)

az container create -g siwoo-rg1 \
  --name siwoo-aci \
  --dns-name-label siwoo-aci \
  --ports 80 \
  --image $acr_server/azure2021:0.0.1 \
  --registry-login-server $acr_server \
  --registry-username $sp_appid \
  --registry-password $sp_pwd