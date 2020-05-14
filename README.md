# Kyle - DevOps test

## Folder structure:
- terraform/

  Terraform code to create AWS Infra in **us-west-2**
  
- ansible/

  Ansible playbook to deploy the app to EC2

- gfgapp/

  Golang app source code

## Prerequisites:
1. Terraform 0.12
```
terraform version
Terraform v0.12.24
```
2. Ansible 2.9
```
ansible --version
ansible 2.9.9
  config file = None
  configured module search path = ['/Users/thunguyen/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 3.7.7 (default, Mar 10 2020, 15:43:33) [Clang 11.0.0 (clang-1100.0.33.17)]
```
3. Golang 1.13.8
```
go version
go version go1.13.8 darwin/amd64
```
4. AWS environment setup. **SET REGION TO us-west-2** ( Due to simplicity, I hardcoded this ;) )

## Flow:
1. Spin up the infra using Terraform
```
cd terraform/
terraform apply -auto-approve -var 'postgres_password=[whatever]'
```
**Example:**
```
terraform apply -auto-approve -var 'postgres_password=gfg654321'
```
NOTE: Copy the output of Terraform "ec2_ip", "rds_endpoint" and "ssh_priv_key" to use in the next step


2. Deploy using Ansible
```
cd ansible/
ansible-playbook -i [Output of Terraform "ec2_ip"], -u ec2-user --private-key [~/.ssh/gfgkey] --extra-vars [Output of Terraform "rds_endpoint] deploy.yml
```
**Example:**
```
ansible-playbook -i 54.202.129.163, -u ec2-user --private-key ~/.ssh/gfgkey --extra-vars "postgres_endpoint=terraform-20200513140901941400000006.coc5vakaf5qu.us-west-2.rds.amazonaws.com" deploy.yml
```
3. (OPTIONAL) Build the Golang app and copy to Asible folder
```
cd gfgapp/
GOOS=linux GOARCH=amd64 go build -o main .
cp main ../ansible/app
```
