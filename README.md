# 🚀 Serverless Image Processing Pipeline

An automated, event driven architecture that processes and optimizes images uploaded to AWS S3 using Lambda and Terraform.

---

## 🏗️ Architecture Overview

The system follows a reactive "Pipe and Filter" design pattern:
1. **Trigger**: An image is uploaded to the **Source S3 Bucket**.
2. **Compute**: S3 triggers an **AWS Lambda** function.
3. **Action**: The Lambda function reads the image, performs processing, and uploads the result to a **Processed S3 Bucket**.
4. **Monitoring**: All execution logs are captured in **Amazon CloudWatch**.



---

## 🛠️ Tech Stack

* **Infrastructure:** Terraform
* **Compute:** AWS Lambda
* **Storage:** Amazon S3
* **Language:** Python 3.14 (Boto3 SDK)
* **Platform:** Ubuntu

---

## 🚦 Getting Started

### 1. Prerequisites
Before you begin, make sure you have the following installed and configured:
*   [Terraform](https://www.terraform.io/downloads.html)
*   [AWS CLI](https://aws.amazon.com/cli/) (configured with appropriate credentials)
*   A Linux environment (like Ubuntu) for zipping the Lambda packages to ensure compatibility.
*   **State Management:** Update the `bucket` name in `terraform.tf` to a unique S3 bucket that you own to store the Terraform state.

### 2. Infrastructure Deployment
Navigate to the root directory and run:

```bash
terraform init
terraform plan
terraform apply -auto-approve