# Serverless Image Processing with AWS & Terraform

This project implements an automated, event-driven pipeline for processing and optimizing images. It leverages AWS Lambda to react to S3 uploads, providing a scalable way to handle image transformations without managing any servers.

## How it works

The architecture follows a simple, reactive flow:

1.  **Upload:** When an image is dropped into the source S3 bucket, it triggers an event.
2.  **Process:** An AWS Lambda function (running Python 3.14) is immediately invoked. It pulls the image, performs the necessary processing—such as resizing or metadata extraction—and then pushes the optimized version to a separate "processed" bucket.
3.  **Monitor:** All logs and execution details are sent to Amazon CloudWatch, making it easy to track performance and debug issues.

## Tech Stack

*   **Infrastructure:** Terraform
*   **Compute:** AWS Lambda (Python 3.14 / Boto3)
*   **Storage:** Amazon S3
*   **Environment:** Ubuntu (Linux)

## Getting Started

### Prerequisites

Before you begin, make sure you have the following installed and configured:

*   [Terraform](https://www.terraform.io/downloads.html)
*   [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)
*   A Linux environment (like Ubuntu) for zipping the Lambda packages to ensure compatibility.

### Deployment

To spin up the infrastructure, navigate to the root directory and run:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Once the apply completes, Terraform will output the names of your source and destination buckets. You can then test the pipeline by uploading an image to the source bucket.
