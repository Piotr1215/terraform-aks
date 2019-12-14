# Prepare Azure resources and setup for cluster creation

This guide is based on [Tutorial: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks)

1. Execute script **create-container.sh** - this will create storage account with container for storing terraform state and initiate terraform

2. Run **terraform plan -out out.plan** - this will prepare terraform deployment

3. Run **terraform apply out.plan** - this will deploy AKS and store terraform state in the container created in step 1

4. Run **echo "$(terraform output kube_config)" > ./azurek8s** - this will create azure config for kubectl

5. Run **export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:./azurek8s** to merge newly created config for AKS with default kubeclt config

6. Run **terraform destroy** to cleanup all AKS related resources

7. Run **az group delete -n \<resource group name from create-container.sh>** - remove storage account and terraform state

8. Run **rm -Rf .terraform** - this is needed to reset the state which is gone when removing the storage account and container