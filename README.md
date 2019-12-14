# Prepare Azure resources and setup for cluster creation

1. Run _create-container.sh_ - this will create storage account with container for storing terraform state and initiate terraform

2. Run _terraform plan -out out.plan_ - this will prepare terraform deployment

3. Run _terraform apply out.plan_ - this will deploy AKS and store terraform state in the container created in step 1

4. Run _echo "$(terraform output kube_config)" > ./azurek8s_ - this will create azure config for kubectl

5. Run _export KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:./azurek8s_ to merge newly created config for AKS with default kubeclt config

6. Run _terraform destroy_ to cleanup all AKS related resources

7. Run _az group delete -n <resource group name from create-container.sh>_ - remove storage account and terraform state

8. Run _rm -Rf .terraform_ - this is needed to reset the state which is gone when removing the storage account and container