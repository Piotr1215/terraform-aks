# Deploy AKS cluster using terraform and Azure CLI

This guide is based on [Tutorial: Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks) with a few differences:

* Azure RBAC is enabled

* automated retrieval of storage account key

* cluster config is merged with kubeclt config file instead of replacing it

## First time deployment using terraform

Deployment might take 10-15 minutes (with 2 node pools)

1. Execute script `create-container.sh` - create storage account with container for storing terraform state and initiate terraform

2. Run `terraform plan -out out.plan` - prepare terraform deployment

3. Run `terraform apply out.plan` - deploy AKS and store terraform state in the container created in step 1

4. Run `az aks get-credentials -g azure-k8stest -n k8stest` to merge newly created config with local kubectl config file and switch to the new cluster

5. Run `kubectl get nodes` - verify that the cluster is selected and you can access it

## Redeploy cluster after running only terraform destroy

1. Run `terraform plan -out out.plan` - this refreshes the plan and prepares for deployment

2. Run `terraform apply out.plan` - spin up AKS cluster, storage account should still be there. Btw there are no additional charges for storage account up to 5GB

## Monitor your cluster

Observability is very important, Azure provides monitoring though Application Insights and Azure Log, but I like to use terminal based dashboard called K9S. Big shoutout to [derailed](https://github.com/derailed) for creating it. You can find [K9S repo here](https://github.com/derailed/k9s) and here is how it looks on my WSL terminal.

![K9S](https://github.com/Piotr1215/azure-architect-exams-resources/blob/master/k9s-dashboard.png?raw=true)

## Additional installations and fun things to try out

Folder [deployments](deployments) contains sample files to play around in the cluster

### Play with official "Guestbook" example

Kubernetes docs site has a very easy to follow sample called "Guestbook" which allows you to test a few k8s features and have a running sample in minutes. [Follow the tutorial here](https://kubernetes.io/docs/tutorials/stateless-application/guestbook/).

### Setup virtual nodes

>Powered by the open source Virtual Kubelet technology, Azure Kubernetes Service (AKS) virtual node allows you to elastically provision additional pods inside Container Instances that start in seconds. With a few clicks in the Azure portal, turn on the virtual node feature and get the flexibility and portability of a container-focused experience in your AKS environment without needing to manage the additional compute resources. And since your Azure Container Instances containers can join the same virtual network as the rest of your cluster, you can build Kubernetes services that seamlessly span pods running on virtual machines (VMs) and Azure Container Instances.
<cite>[Azure Kubernetes Service (AKS) virtual node is in preview](https://azure.microsoft.com/en-us/updates/aks-virtual-node-public-preview/)</cite>.

[Youtube vid by  Sam Cogan about using virtual nodes in AKS](https://youtu.be/LhOCFJZp1H0)

[Use Azure CLI to enable virtual nodes on already deployed cluster](https://docs.microsoft.com/en-us/azure/aks/virtual-nodes-cli)

### See what's all the fuss with Dapr

1. Make sure that helm version is >=3.0, run `helm version --short`

2. Install Dapr

    Dapr is open an source event-driven, portable runtime for building microservices on cloud and edge, you can find our more on [Dapr website](https://dapr.io/).

    [Announcing Dapr](https://cloudblogs.microsoft.com/opensource/2019/10/16/announcing-dapr-open-source-project-build-microservice-applications/)

    ```bash
    helm repo add dapr https://daprio.azurecr.io/helm/v1/repo
    helm repo update
    kubectl create ns dapr-system
    helm install dapr dapr/dapr --namespace dapr-system
    ```

3. If you have Error: Kubernetes cluster unreachable, run `kubectl config view --raw >~/.kube/config`

## Cleanup

1. Run `terraform destroy` - cleanup all AKS related resources

2. __WARNING: Full Cleanup__ Run `az group delete -n \<resource group name from create-container.sh>` - remove storage account and terraform state

3. __WARNING: Full Cleanup__ Run `rm -Rf .terraform` - this is needed to reset the state which is gone when removing the storage account and container
