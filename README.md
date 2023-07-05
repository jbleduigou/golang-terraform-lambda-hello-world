# 🚀 Go and Terraform with Lambda Functions

This project demonstrates the usage of Go and Terraform in conjunction with AWS Lambda functions.  
It specifically highlights the differences between utilizing x86 processors and Graviton (ARM-based) processors.

## Installation

To get started with this project, follow the steps below:

1. Clone the repository:

   ```bash
   git clone https://github.com/jbleduigou/golang-terraform-lambda-hello-world.git
   ```

2. Install Go (version 1.20) on your machine. You can download and install it from the official Go website: https://golang.org/dl/
3. Install Terraform. You can use the provided GitHub Actions workflow or install Terraform manually from the official Terraform website: https://www.terraform.io/downloads.html
4. Install the project dependencies. Run the following command in the project root directory:
   ```bash
    go get -v -t -d ./...
   ```

## Compilation

In order to build the project simply run the following command:
```bash
make build
```
This command will compile the Go code and generate the necessary zip files for the Lambda functions.

## Deployment

To deploy the project to AWS Lambda, you can use Terraform. Follow the steps below:

1. Initialize Terraform in the project root directory:

    ```bash
    terraform init
    ```

2. Validate the Terraform configuration:

    ```bash
    terraform validate
    ```

3. Deploy the Lambda functions and associated resources using Terraform:

    ```bash
    terraform apply
    ```
Terraform will provision the Lambda functions, IAM roles, CloudWatch log groups, and API Gateway resources required for the project

## Architecture Options
This project offers two main architecture options for deploying the Lambda functions:

* x86 Architecture: Utilizes x86 processors for the Lambda function. The function can be accessed using the route `GET /x86` through the API Gateway.
* Graviton (ARM-based) Architecture: Utilizes Graviton processors for the Lambda function. The function can be accessed using the route `GET /arm64` through the API Gateway.

If you look closely at the Terraform you can see that the Graviton lambda function uses the runtime `provided.al2`.  
This is because so far, AWS has not provided an official Go runtime for ARM processors.

## Contributing
Contributions to this project are welcome! If you have any suggestions, improvements, or bug fixes, please submit a pull request.

## License
This project is licensed under the [Apache License 2.0](LICENSE).