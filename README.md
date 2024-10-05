# Terraform Projects Best Practices - AWS

## Project Overview

This project demonstrates how to effectively structure Terraform code for managing infrastructure. It utilizes modularization and splitting resources into tiers based on how frequently they change or how their changes are correlated. The project follows a multi-tiered structure to organize resources based on their volatility.

### Project Structure

- **init/**: Contains Terraform configuration that sets up core infrastructure components required for managing Terraform state. This includes the creation of the S3 bucket for storing state, the DynamoDB table for state locking, and the IAM role for managing access to these resources.
  
- **environments/**: Holds subfolders for each environment (e.g., `dev/`, `staging/`, `prod/`). Each environment has its own Terraform configuration, but shares the same backend, storing its state in the S3 bucket created during the `init` step.

### Key Resources

1. **S3 Bucket**: Stores versioned Terraform state files securely.
2. **DynamoDB Table**: Provides state locking to ensure that only one operation can modify the state at a time.
3. **IAM User Role**: Grants appropriate permissions to interact with the state management components, ensuring secure access.

## Prerequisites

- [Terraform CLI](https://www.terraform.io/downloads.html)
- AWS account credentials configured in your environment or provided via Terraform variables

## Instructions

### 1. Initial Setup (`init/`)

The `init` folder contains Terraform code to initialize the resources necessary for state management and access control. This projects will never be touched again after the initial setup.

#### Steps:

1. Navigate to the `init/` directory:
   ```bash
   cd init/
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the configuration to create the necessary resources:
   ```bash
   terraform apply
   ```

   This will:
   - Create the S3 bucket with versioning enabled for storing Terraform state.
   - Create the DynamoDB table for state locking.
   - Set up an IAM user with the required permissions to manage the Terraform state and locking.

4. The Terraform state for the `init/` step will be stored in the Git repository itself since this represents the foundational infrastructure that needs to be persistent.

### 2. Managing Environments (`environments/`)

The `environments` folder contains subfolders for each environment (`development`, `production`). Each environment manages its own resources but shares the same S3 bucket that was created during the `init` step to store the state files. 

#### Steps:

1. Navigate to the desired environment, e.g., `dev`:
   ```bash
   cd environments/development/
   ```

2. Initialize Terraform with the backend configuration:
   ```bash
   terraform init
   ```

3. Apply the configuration to provision the environment-specific resources:
   ```bash
   terraform apply
   ```

   The state file will be securely stored in the S3 bucket, and any state changes will be locked using the DynamoDB table.

### 3. Backend Configuration

Each environment stores its Terraform state in the S3 bucket created during the `init` step. Here’s a sample backend configuration used in each environment:

```hcl
terraform {
  backend "s3" {
    bucket         = "companyname-tfstate"  # Replace with your S3 bucket name
    key            = "development"                # Adjust for each environment
    region         = "us-east-1"                                # Replace with your region
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Structuring for Scalability

As your infrastructure grows, it’s essential to structure your code in tiers, based on how frequently different components change:

- **Frequently Changing Components**: Group components that are modified regularly (e.g., application deployments, ECS clusters, scaling policies) together. This ensures flexibility and faster iterations when working on dynamic parts of your infrastructure.
  
- **Static Components**: Group infrastructure elements that change infrequently (e.g., VPC, subnets, networking components) separately. These parts of the infrastructure typically don't require frequent updates and are better managed in a separate tier.

This tiered approach enables you to scale your infrastructure without complicating your deployment pipelines and reduces the likelihood of unnecessary state modifications.

## Folder Structure

```
.
├── init/
│   ├── main.tf        # Terraform code to create the S3 bucket, DynamoDB table, and terraform backend IAM user
│   ├── outputs.tf     # Outputs for reference
├── environments/
│   ├── development/
│   │   ├── main.tf    # Resources for the development environment
│   ├── production/
│   │   ├── main.tf    # Resources for the production environment
└── README.md          # Project documentation
```

## Best Practices

- **Versioned State**: The state file is stored with versioning enabled to protect against accidental overwrites or corruption.
- **State Locking**: Use DynamoDB for locking to prevent concurrent changes to the same state file.
- **Environment Separation**: Separate environments ensure isolated configurations and state for each stage (dev, staging, production), which is essential for managing infrastructure lifecycles effectively.
