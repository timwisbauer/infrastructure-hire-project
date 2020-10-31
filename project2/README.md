# Infrastructure Hire Project 2

# Overview

This project will deploy an EKS cluster and run a handful of services on it.

1. vulns-app - Flask web app that retrieves vulnerability information from a S3 bucket and either displays the vulnerabilities or counts of LOW/MEDIUM/HIGH vulnerabilities per vendor.
2. nginx-evil - Displays nginx start page.
3. proxy - Flask web app to proxy requests to vulns-app and nginx-evil.

# Setup

You will need the following:

* A fork of this repository
* An AWS account
* Docker
* Python
* Terraform
* `kubectl`

# Usage

1. Clone this repository.
2. CD into the cloned directory.
3. Build docker images.
   1. `docker build -t proxy project2/flask/proxy`
   2. `docker build -t vulns-app project2/flask/vulns-app`
4. CD into terraform directory. `cd project2/terraform`
5. `terraform init`
6. `terraform apply`
7. After a few minutes, Terraform will display the hostname to access the web applications.  Note: You may need to wait a couple of minutes for DNS replication to finish.

URL Endpoints:  
/test - Displays "it works!" from proxy.  
/vulns - Displays vulnerability information from vulns-app.  
/stats - Displays counts of vulnerability severity per vendor from vulns-app.  
/evil - nginx start page.  

# Tasks

- [X] Create an S3 bucket in Terraform (this will be used by the container running in EKS)

- [X] Python script

    Write a Python script to read the `example.json` file from the S3 bucket, calculate the counts of how many `LOW`, `MEDIUM`, and `HIGH` vulnerabilities are seen PER `vendor_id`, and upload a results file to the same S3 bucket, or return via http request.

- [X] Create a Docker image for the Python script

- [X] Create an ECR registry for the image

- [X] Create the appropriate Kubernetes manifest(s) to run the Python script.

- [X] Create an IAM role to be associated with the Kubernetes resource to allow the script to access S3

### Senior Candidates (or anyone looking to have some more fun!)
For a senior candidate we'd like to explore more into your Kubernetes knowledge. In the flask directory, there are two python apps and a requirements file, that can be used a template to create your web service. We would like you to create a simple web service (using a proxy) to return the vulnerability data via the proxy service from previously created script.

- [X] Update the Python script previously created to be a Flask application that returns the vulnerability data via HTTP (using `vuln.py` as the starting point)

- [X] Update the Docker image to run the Flask application

- [X] Deploy the Flask application (`vuln.py`) to Kubernetes

- [X] Update `proxy.py` with the appropriate endpoints for vulnerability service

- [X] Create a Docker image for the `proxy.py` service

- [X] Deploy the proxy service to Kubernetes using an ALB for ingress

- [X] Test that GET /vulns returns the appropriate data

#### Optional

- [X] Deploy a basic NGINX service and test you can get access via GET /evil endpoint
  
- [ ] Utilizing a CNI or service mesh and restrict access from the proxy service to the nginx service

# Next steps

- [ ] Install Calico and implement network policies restricting access between pods to only what is required.  An alternative would be using EC2 Security Groups, but they aren't supported on the selected instance type and have other limitations around the number of pods on each node.
- [ ] Set up autoscaling.  Install metrics-server and configure horizontal pod autoscalers (along with pod CPU requests).  Also configure cluster autoscaling.
- [ ] ALB improvements.  HTTPS, redirect HTTP to HTTPS, redirect root URL.
- [ ] Export pod logs to CloudWatch.
