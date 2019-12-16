# Create general purpose V2 storage account

accountName=csstorageforakstest222
rg=terraform-storage-rg

az group create --name $rg --location westeurope --output json

az storage account create \
    --name $accountName \
    --resource-group $rg \
    --location westeurope \
    --sku Standard_RAGRS \
    --kind StorageV2

# Create container to host terraform state
# 1. retrieve storage account key:

accountKey=$(az storage account keys list --account-name $accountName --resource-group $rg \
--query "[?keyName == 'key1'].value" -o tsv)

az storage container create -n tfstate --account-name $accountName --account-key $accountKey

terraform init -backend-config="storage_account_name=$accountName" \
-backend-config="container_name=tfstate" \
-backend-config="access_key=$accountKey" \
-backend-config="key=dev.tfstate"
