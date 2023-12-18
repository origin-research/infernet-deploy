# Infernet Node Deployment

Deploy a cluster of heterogenous [Infernet](https://github.com/origin-research/jazz) nodes on Amazon Web Services (AWS) and / or Google Cloud Platform (GCP), using [Terraform](https://www.terraform.io/) for infrastructure procurement and [Docker compose](https://docs.docker.com/compose/) for deployment.


### Setup
1. [Install Terraform](https://developer.hashicorp.com/terraform/install)
2. **Configure nodes**: A node configuration file **for each** node being deployed.
    - See [example configuration](configs/0.json.example).
    - They must be named `0.json`, `1.json`, etc...
    - They must be placed under the top-level `configs/` directory.
    - Each node *strictly* requires its own configuration `.json` file, even if those are identical.
    - For instructions on configuring nodes, refer to the [Infernet repo](https://github.com/origin-research/jazz).


### Deploy on AWS

1. [Authenticate](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html) with the AWS CLI on your machine.

2. Make a copy of the example configuration file [terraform.tfvars.example](procure/aws/terraform.tfvars.example):
    ```bash
    cd procure/aws
    cp terraform.tfvars.example terraform.tfvars
    ```
3. Configure your `terraform.tfvars` file. See [variables.tf](procure/aws/variables.tf) for config descriptions.

4. Run Terraform:
    ```bash
    # Initialize
    cd procure
    make init provider=aws

    # Print deployment plan
    make plan provider=aws

    # Deploy
    make apply provider=aws

    # WARNING: Destructive
    # Destroy deployment 
    make destroy provider=aws
    ```

### Deploy on GCP


1. [Authenticate](https://cloud.google.com/docs/authentication/gcloud) with the GCloud CLI on your machine.

2. Make a copy of the example configuration file [terraform.tfvars.example](procure/gcp/terraform.tfvars.example):
    ```bash
    cd procure/gcp
    cp terraform.tfvars.example terraform.tfvars
    ```
3. Configure your `terraform.tfvars` file. See [variables.tf](procure/gcp/variables.tf) for config descriptions.

4. Run Terraform:
    ```bash
    # Initialize
    cd procure
    make init provider=gcp

    # Print deployment plan
    make plan provider=gcp

    # Deploy
    make apply provider=gcp

    # WARNING: Destructive
    # Destroy deployment 
    make destroy provider=gcp
    ```
