# lesson-8-9

This folder builds a CI/CD setup for the Django app.

Terraform creates an EKS cluster, Jenkins, and Argo CD. Jenkins builds a Docker image and pushes it to ECR. Then Jenkins writes the new image tag into the Helm chart and pushes that commit. Argo CD reads the chart from Git and updates the app in the cluster.

The Jenkinsfile is in the root of the repo. The chart is in lesson-8-9/charts/django-app.

## What Terraform creates

- S3 bucket and DynamoDB table for Terraform state
- VPC and EKS cluster lesson-8-9-eks (t3.small nodes)
- EBS CSI driver and StorageClass ebs-sc
- ECR repository lesson-8-9-django
- Jenkins in namespace jenkins
- Argo CD in namespace argocd, plus Application django-app
- metrics-server for the HPA

This is a separate cluster from lesson-7.

## Before apply

Create a GitHub token for user andreydos. It needs write access to the docc repo. Do not commit the token.

From the repo root:

```bash
cp lesson-8-9/terraform.tfvars.example lesson-8-9/terraform.tfvars
```

Put the token in lesson-8-9/terraform.tfvars.

Push branch lesson-8-9 to GitHub before the second apply. Argo CD reads the chart from that branch.

## Apply

```bash
cd lesson-8-9
terraform init
terraform apply -target=module.vpc -target=module.ecr -target=module.eks
terraform apply
```

If terraform init says the S3 bucket does not exist, comment out the backend block in backend.tf, run terraform apply -target=module.s3_backend, put the backend block back, then run terraform init -migrate-state.

Connect kubectl:

```bash
aws eks update-kubeconfig --region us-west-2 --name lesson-8-9-eks
kubectl get nodes
```

Delete everything:

```bash
terraform destroy
```

## Jenkins

Login is admin / admin123.

Get the address:

```bash
kubectl get svc -n jenkins jenkins
```

Open the LoadBalancer hostname on port 80.

Jobs django-docker and seed-job are already there. Open django-docker and click Build Now. You do not need to run seed-job.

The job builds django/Dockerfile with Kaniko, pushes lesson-8-9-django:v1.0.BUILD_NUMBER to ECR, updates image.tag in lesson-8-9/charts/django-app/values.yaml, and pushes that change to branch lesson-8-9. The commit message contains [skip ci], so this commit does not start the job again.

Check the result:

```bash
aws ecr describe-images --repository-name lesson-8-9-django --region us-west-2
git pull origin lesson-8-9
```

image.tag in values.yaml should be v1.0.N.

## Argo CD

Get the admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
```

Username is admin.

Get the address:

```bash
kubectl get svc -n argocd argo-cd-server
```

Open the LoadBalancer hostname on port 443. The certificate is self-signed.

Application django-app watches lesson-8-9/charts/django-app on branch lesson-8-9. After the tag commit it should become Synced and Healthy, and the new pod should use tag v1.0.N.

```bash
kubectl get applications -n argocd
kubectl get pods
kubectl get svc
```

## Hand-in

Push branch lesson-8-9. The LMS zip is lesson-8-9_NAME.zip. Do not put .terraform, terraform.tfstate, or terraform.tfvars in the zip.
