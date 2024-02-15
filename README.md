# flask-health-api
This repo contains basic flask app which has health endpoint and Docker file to dockerize and terraform script to create infra in gcp .

This repo contains main.tf,variables.tf,output.tf three terraform files now after cloning this repo you need to following things

1. Download the credentials.json file of GCP service account which has access to create infra in gcp and copy to the repo location
2. Create one more file terraform.tfvars which need to have 3 things 
     project ( GCP project where we need to create infra )
     credentials_file ( path to json file we copied )
     cidr_range (ip range for subnet )
     
sample terraform.tfvars
project = "<name-of-project>"
credentials_file = "<path-to-json-file>"
cidr_range = "10.0.1.0/24"

3. Now both files are there run terraform plan command
4. verify the plan and run terraform apply
5. wait for 10-15 mins as we are creating lot of resources
6. once apply is sucessful it will display lb_ip (Google loadbalancer ip) as output
7. wait for 5 mins and hit http://<lb_ip>/health
8. you should see sucessful response similar to this :{"error":false,"result":"Healthy"}
