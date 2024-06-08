#!/bin/bash

# Mettre à jour la liste des paquets
sudo apt-get update

# Installer les dépendances nécessaires
sudo apt-get install -y gnupg software-properties-common curl python3 python3-pip python3-venv

# Ajouter la clé GPG de HashiCorp
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Ajouter le dépôt officiel de HashiCorp
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Mettre à jour la liste des paquets et installer Terraform
sudo apt-get update
sudo apt-get install -y terraform

# Créer un environnement virtuel pour Ansible
python3 -m venv ~/ansible-venv

# Activer l'environnement virtuel
source ~/ansible-venv/bin/activate

# Installer Ansible dans l'environnement virtuel
pip install ansible

# Vérifier les installations
terraform -v
ansible --version

# Désactiver l'environnement virtuel
deactivate
