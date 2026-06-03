# Project Overview


## Steps for regeneration:

- First, install Azure CLI for you machine. I assume you have a Windwos machine. And hence, you can do: `winget install --exact --id Microsoft.AzureCLI` (Assuming you have Winget installed)
- Sign in with your Azure Account as `az login`. You will be prompted for your credentials and enter your details. Furthermore, if you encounter issues related to something along the lines of ***"...No tenant found..."***, you may need to give it your `tenant_id` which is available from your portal.
- To find the `tenant_id`, open your portal and search for Microsoft Entra ID and copy the **Tenant ID** value
- The [main.tf](./main.tf) and [variable.tf](./variable.tf) are there to facilitate terraform to provision resources in Azure. Initialize it as `terraform init` followed by `terraform plan -var-file="secret.tfvars` where the `secret.tfvars` file hold the `subscription_id` for the account.
- For production, I advise to keep the `tfplan` file. The way to generate it is: `terraform plan -var-file="secret.tfvars" -out=tfplan`
- To actually create the resource groups now, you have to then run: `terraform apply "tfplan"`
- If you don't have a Service Principles for GitHub, you can create it as following:
``` bash
# Bash script
az ad sp create-for-rbac --name myServicePrincipalName1 --role <role(reader, contributor)> --scopes /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myRG1
# Check out Azure CLI docs at:  https://aka.ms/azadsp-cli for more
```
- The Service Principle command will give you `Tenant ID, App ID, Display Name, Password` in JSON dump.
- Create `AZURE_CREDENTIALS` secret for your repo in GitHub and deploy the application on the final commit and push. If something fails, check your credentials again or check your resource groups in the Azure Portal. ***Note**: I failed when the Dockerfile had a typo*

> **Notes:** Check your `secrets.tfvar` when using any command that involves provisioning or Terraform in general. Most of the time, it is authentication, so, be sure to check creds whether in GitHub secrets or check out your Azure Portal.

> **Note 2:** Had to join a subscription to Microsoft.app to apply [main.tf](./main.tf). Anyone seeing this can do the same by going to your **Subscriptions** and then find and click your subscription(mine is Student for this case, yours might be different) and in the left side of the screen which lists different configuration, find **Resource Providers** under **Settings**