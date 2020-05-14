preseed:
  cd ansible/
  ansible-playbook -y preseed.yml
deploy:
  cd terraform/
  terraform apply -auto-approve
  cd ../ansible
  ansible-playbook -y deploy.yml
