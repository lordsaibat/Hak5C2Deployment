# Environment Setup Instructions
Sign up for a google cloud account [https://console.cloud.google.com/]

You need to create a project [https://cloud.google.com/resource-manager/docs/creating-managing-projects]

Make note of the Project ID 

## Setup a service account
Setting up your credentials for terraform to use [https://www.terraform.io/docs/providers/google/guides/getting_started.html#adding-credentials]

Place your service account json details into the gcloud.json file

## Tools needed
Terraform [https://www.terraform.io/downloads.html]

(optional) Cloud SDK [https://cloud.google.com/sdk/docs/downloads-versioned-archives]

# Todo before you try to deploy
- Edit the hak5-c2.tf file:
  -  Update the project line.  
  -  Update the ports/listen port line, if you want to have a different web interface port.
- In the ssh_keys directory, generate ssh keys for the instance by running the following command:
  
    `ssh-keygen -f gkeys `

## HTTPS Version
Edit the hak5_c2.tf file:
- Uncomment the first hostname line and comment the second line.
- 
  ```
  module "C2-run" {
  source = "./modules/null_resource"
  hostname = "example.com"
  //hostname = "${module.hak5-c2.ip}"
  listenip = "${module.hak5-c2.ip}"
  listenport = "443"
  }
  ```
  
- Edit the ./modules/null_resources/main.tf file by commenting the first line in "remote-exec" statement and uncomment the second line as below:
- 
  ```
    provisioner "remote-exec" {
     inline = [
     //"cd ./hak5;sudo screen -S hak5 -d -m nohup /home/guser/hak5/c2_community-linux-64 -hostname ${var.hostname} -listenport ${var.listenport}", //http
     "cd ./hak5;sudo screen -S hak5 -d -m nohup /home/guser/hak5/c2_community-linux-64 -hostname ${var.hostname} -listenport ${var.listenport} -https", //https 
     "sleep 30",
    ]
  }
  ```

Update your DNS record to point to the new ip.

# Deployment instructions
Initialize the terraform deployment.
`terraform init`

Deploy the infrastructure.
`terraform apply`

ssh into your new instance:

`ssh guser@<IP> -i ./ssh_keys/gkeys`

and run the following command to obtain the setup key:

`sudo cat ~/hak5/nohup.out`


# Limitations
This deployment uses the default flags needed to run Cloud C2 .

If you want to run different options for Cloud C2, you would need to edit the following line(s) in ./modules/null_resources/main.tf file:

 ```
provisioner "remote-exec" {
     inline = [
     //"cd ./hak5;sudo screen -S hak5 -d -m nohup /home/guser/hak5/c2_community-linux-64 -hostname ${var.hostname} -listenport ${var.listenport}", //http
     "cd ./hak5;sudo screen -S hak5 -d -m nohup /home/guser/hak5/c2_community-linux-64 -hostname ${var.hostname} -listenport ${var.listenport} -https", //https 
     "sleep 30",
    ]
  }
  ```

