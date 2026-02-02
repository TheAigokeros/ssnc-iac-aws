# ssnc-iac-aws
simple terraform for test

terraform init
terraform plan -var-file=<file> -out=plan.out

terraform apply -var-file=plan.out 
or 
terraform apply <out file>


---
## other command
```
terraform state list
```