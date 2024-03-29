#!/bin/bash
# Exit if any of the intermediate steps fail
set -e
sonar_url=$1
sonar_user_name=$2
sonar_password=$3
github_token=$4
github_repo_url=$5
service_name=$6
github_user_name=$7
programming_language=$8

export GITHUB_TOKEN=$github_token
## cloning code from gitrepo
echo "Setting up git credentials" && git config --global credential.helper 'store' && echo "https://$github_user_name:$github_token@github.com" > ~/.git-credentials

git clone $github_repo_url /tmp/$service_name 

# downloding sonar scanner 
wget -q https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
unzip  -q  sonar-scanner-cli-4.7.0.2747-linux.zip
export PATH=$PATH:./sonar-scanner-4.7.0.2747-linux/bin/
if [$programming_language eq dotnet]; then
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  cd /tmp/$service_name 
  dotnet-sonarscanner begin /k:$service_name /d:sonar.host.url=http://"$sonar_url"  /d:sonar.login="$sonar_user_name"  /d:sonar.password="$sonar_password"
  dotnet build 
  dotnet-sonarscanner end  /d:sonar.login="$sonar_user_name"  /d:sonar.password="$sonar_password"
elif [$programming_language eq java]; then
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  cd /tmp/$service_name 
  mvn clean verify sonar:sonar -Dsonar.projectKey="$service_name" -Dsonar.host.url=http://"$sonar_url" -Dsonar.login="$sonar_user_name" -Dsonar.password="$sonar_password"
else
  echo "Running sonar scanner with sonar username=$sonar_user_name password=$sonar_password ........"
  cd /tmp/$service_name 
  sonar-scanner -Dsonar.login="$sonar_user_name" -Dsonar.password="$sonar_password" -Dsonar.projectKey="$service_name" -Dsonar.host.url=http://"$sonar_url"
fi
