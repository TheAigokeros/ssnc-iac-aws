# Go Hello World Application

A simple Go HTTP server that serves a "Hello, World!" message.

## Features

- Serves on port 8080 (configurable via PORT environment variable)
- Health check endpoint at `/health`
- Main endpoint at `/` returns a greeting message

## Building the Docker Image

### For AWS ECR:

1. Create an ECR repository (or use existing):
```bash
aws ecr create-repository --repository-name hello-world --region us-east-1
```

2. Get the login token and authenticate:
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

3. Build the image:
```bash
docker build -t hello-world .
```

4. Tag the image:
```bash
docker tag hello-world:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
```

5. Push to ECR:
```bash
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest
```

6. Update `terraform/variables.tf` with the ECR image URL, or pass it as a variable:
```bash
terraform apply -var="container_image=<account-id>.dkr.ecr.us-east-1.amazonaws.com/hello-world:latest"
```

### For Docker Hub:

1. Build and tag:
```bash
docker build -t your-username/hello-world:latest .
```

2. Push:
```bash
docker push your-username/hello-world:latest
```

3. Update `terraform/variables.tf` or pass as variable:
```bash
terraform apply -var="container_image=your-username/hello-world:latest"
```

## Local Testing

Run locally:
```bash
go run main.go
```

Or with Docker:
```bash
docker build -t hello-world .
docker run -p 8080:8080 hello-world
```

Then visit `http://localhost:8080` or `http://localhost:8080/health`
