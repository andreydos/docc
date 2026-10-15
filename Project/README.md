# Final project

One Terraform stack in `us-west-2` for the DevOps final project. It builds on the lesson modules: network and EKS from lesson 8–9, PostgreSQL from the database module, plus Prometheus and Grafana.

Terraform creates:

- an S3 bucket and a DynamoDB table for the Terraform state
- a VPC `10.3.0.0/16` with public and private subnets
- an EKS cluster `final-eks` (2 × t3.medium, up to 3)
- an ECR repository `final-django`
- PostgreSQL 17 on RDS `db.t3.micro` in the private subnets
- Jenkins in namespace `jenkins`
- Argo CD in namespace `argocd`, plus Application `django-app`
- Prometheus and Grafana in namespace `monitoring`
- metrics-server for the HPA

The Django chart is `charts/django-app`. Jenkins builds `Django/Dockerfile`, pushes the image to ECR, and commits a new `image.tag`. Argo CD deploys that chart from git. The app reads the RDS address from the Kubernetes secret `django-rds`, which Terraform creates. The database security group allows port 5432 only from the VPC CIDR.

## Before apply

Create a GitHub token for user andreydos. It needs write access to the docc repo. Do not commit the token or the database password.

From the repo root:

```bash
cp Project/terraform.tfvars.example Project/terraform.tfvars
```

Set `github_token` and `db_password` in `Project/terraform.tfvars`.

Push branch `final-project` to GitHub before the full apply. Argo CD and Jenkins both read that branch. The course text calls the branch `final project`. This stack uses `final-project`, without a space, because the Jenkinsfile and Argo CD pass the name to git.

If the S3 bucket does not exist yet, comment out the `backend` block in `backend.tf`, then:

```bash
cd Project
terraform init -backend=false
terraform apply -target=module.s3_backend
```

Put the backend block back and run:

```bash
terraform init -migrate-state
```

## Apply

```bash
cd Project
terraform init
terraform apply
```

Connect kubectl:

```bash
aws eks update-kubeconfig --region us-west-2 --name final-eks
kubectl get nodes
```

Check the three namespaces from the assignment:

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
```

## Jenkins

Login is admin / admin123.

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Open http://localhost:8080. Job `django-docker` is already there. Click Build Now. You do not need to run `seed-job`.

The job builds `Project/Django/Dockerfile` with Kaniko, pushes `final-django:v1.0.BUILD_NUMBER` to ECR, updates `image.tag` in `Project/charts/django-app/values.yaml`, and pushes that change to branch `final-project`. The commit message contains `[skip ci]`, so this commit does not start the job again.

## Argo CD

Username is admin. Get the password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo
```

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Open https://localhost:8081. The certificate is self-signed.

Application `django-app` watches `Project/charts/django-app` on branch `final-project`. After the tag commit it should become Synced and Healthy. The pod uses secret `django-rds` for `POSTGRES_HOST` and the password, so it connects to RDS instead of a database inside the cluster.

```bash
kubectl get applications -n argocd
kubectl get pods
kubectl get svc
kubectl get hpa
```

The chart starts two replicas and scales up to six when CPU stays above 70%.

## Grafana and Prometheus

Login is admin / admin123.

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Open http://localhost:3000. Prometheus is already the default data source (`http://prometheus-server.monitoring.svc.cluster.local:80`). A Node Exporter dashboard is imported from grafana.com (id 1860). To add another one: **+ → Import**, enter the dashboard id, choose Prometheus, click Import.

Prometheus UI:

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9090:80
```

Open http://localhost:9090 and check **Status → Target health**.

## Delete everything

```bash
cd Project
terraform destroy
```

`destroy` also deletes the S3 bucket and the DynamoDB lock table. To create them again, comment out the backend in `backend.tf`, run `terraform apply -target=module.s3_backend`, put the backend back, then run `terraform init -migrate-state`.

This stack is a separate cluster from lesson-7 and lesson-8-9. Shut it down when you are not using it. EKS, NAT, the load balancer for the Django service, and RDS are the expensive parts.

## Hand-in

Push branch `final-project`. The zip name is `final_DevOps_ПІБ.zip`. Do not put `.terraform`, `terraform.tfstate`, or `terraform.tfvars` in the zip.
