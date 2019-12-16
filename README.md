# Deploy AKS cluster using terraform and Azure CLI

This guide is based on [Tutorial: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks) with a few differences:

* Azure RBAC is enabled

* automated retrieval of storage account key

* cluster config is merged with kubeclt config file instead of replacing it

## First time deployment

1. Execute script `create-container.sh` - create storage account with container for storing terraform state and initiate terraform

2. Run `terraform plan -out out.plan` - prepare terraform deployment

3. Run `terraform apply out.plan` - deploy AKS and store terraform state in the container created in step 1

4. Run `echo "$(terraform output kube_config)" > ./azurek8s` - create azure config for kubectl

5. Copy AKS cluster configuration to your home direcrory and merge it with existing config file. This is only for the duration of shell session, we don't have to append the export command to bash or zsh config files.

   * Copy `cp azurek8s ~/.kube/`

   * Merge with existing config `export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube//azurek8s` - this way, the cluster will be accesible from every directory

6. Run `kubectl get nodes` - verify that the cluster is selected and you can access it

## Redeploy cluster after running only terraform destroy

1. Run `terraform plan -out out.plan` - this refreshes the plan and prepares for deployment

2. Run `terraform apply out.plan` - spin up AKS cluster, storage account should still be there. Btw there are no additional charges for storage account up to 5GB

## Additional installations

Folder [deployments](deployments) contains sample files to play around in the cluster

### Dapr

1. Make sure that helm version is >=3.0, run `helm version --short`

2. Install Dapr

    Dapr is open an source event-driven, portable runtime for building microservices on cloud and edge, you can find our more on [Dapr website](https://dapr.io/).

    [Announcing Dapr](https://cloudblogs.microsoft.com/opensource/2019/10/16/announcing-dapr-open-source-project-build-microservice-applications/)

    ```bash
    helm repo add dapr https://daprio.azurecr.io/helm/v1/repo
    helm repo update
    helm install dapr dapr/dapr --namespace dapr-system
    ```

3. If you have Error: Kubernetes cluster unreachable, run `kubectl config view --raw >~/.kube/config`

## Cleanup

1. Run `terraform destroy` - cleanup all AKS related resources

2. __WARNING: Full Cleanup__ Run `az group delete -n \<resource group name from create-container.sh>` - remove storage account and terraform state

3. __WARNING: Full Cleanup__ Run `rm -Rf .terraform` - this is needed to reset the state which is gone when removing the storage account and container
