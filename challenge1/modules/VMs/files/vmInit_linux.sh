/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
sudo apt install linuxbrew-wrapper
brew install kubernetes-cli
brew cask install docker
$ sudo apt-get update
$ wget https://vstsagentpackage.azureedge.net/agent/2.174.2/vsts-agent-linux-x64-2.174.2.tar.gz
$ mkdir /home/azureuser/agent
$ Sudo tar -xvf vsts-agent-linux-x64-2.174.2.tar.gz -C /home/azureuser/agent
$ usermod -aG sudo azureuser
$ chmod o+w agent
$ ./config.sh
$  sudo ./svc.sh install
$  sudo ./svc.sh start
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
$ sudo apt update
$ apt-cache policy docker-ce
$ sudo apt install docker-ce
$ curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
$ curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
$ curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
$ sudo setfacl --modify user:azureuser:rw /var/run/docker.sock
$ sudo usermod -aG docker azureuser
$ sudo chmod -R 0777 /home