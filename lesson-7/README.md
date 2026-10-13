# lesson-7

Terraform project for AWS in `us-west-2`.

It creates:

- an S3 bucket and a DynamoDB table for the Terraform state
- a VPC with public and private subnets
- an EKS cluster
- an ECR repository for the Django image

The Django app is deployed with the Helm chart in `charts/django-app`.

The state file is stored in S3 (`lesson-7/terraform.tfstate`), not in git.

## Commands

Run these from the `lesson-7` folder:

```bash
terraform init
terraform plan
terraform apply
terraform destroy
```

`destroy` also deletes the S3 bucket and DynamoDB table that keep the state. To create them again, comment out the backend in `backend.tf`, run `terraform apply`, put the backend back, then run `terraform init -reconfigure`.

Connect kubectl:

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-7-eks
kubectl get nodes
```

Push the image. Replace `ECR_URL` with the value from `terraform output ecr_repository_url`.

```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ECR_URL
docker build -t lesson-7-django ../django
docker tag lesson-7-django:latest ECR_URL:latest
docker push ECR_URL:latest
```

Put the same URL in `charts/django-app/values.yaml` (`image.repository`).

Install metrics-server, then the chart:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
cd charts/django-app
helm install my-django .
```

Update after changes:

```bash
helm upgrade my-django .
```

Check:

```bash
kubectl get pods
kubectl get svc
kubectl get hpa
```
