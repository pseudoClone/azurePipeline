# Project Overview


## Steps for regeneration:

- First, install Azure CLI for you machine. I assume you have a Windows machine. And hence, you can do: `winget install --exact --id Microsoft.AzureCLI` (Assuming you have Winget installed)
- Sign in with your Azure Account as `az login`. You will be prompted for your credentials and enter your details. Furthermore, if you encounter issues related to something along the lines of ***"...No tenant found..."***, you may need to give it your `tenant_id` which is available from your portal.
- To find the `tenant_id`, open your portal and search for Microsoft Entra ID and copy the **Tenant ID** value
- The [main.tf](./main.tf) and [variable.tf](./variable.tf) are there to facilitate terraform to provision resources in Azure. Initialize it as `terraform init` followed by `terraform plan -var-file="secret.tfvars` where the `secret.tfvars` file hold the `subscription_id` for the account.
- For production, I advise to keep the `tfplan` file. The way to generate it is: `terraform plan -var-file="secret.tfvars" -out=tfplan`
- To actually create the resource groups now, you have to then run: `terraform apply "tfplan"`
- If you don't have a Service Principals for GitHub, you can create it as following:
``` bash
# Bash script
az ad sp create-for-rbac --name myServicePrincipalName1 --role <role(reader, contributor)> --scopes /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myRG1
# Check out Azure CLI docs at:  https://aka.ms/azadsp-cli for more
```
- The Service Principals command will give you `Tenant ID, App ID, Display Name, Password` in JSON dump.
- Create `AZURE_CREDENTIALS` secret for your repo in GitHub and deploy the application on the final commit and push. If something fails, check your credentials again or check your resource groups in the Azure Portal. ***Note**: I failed when the Dockerfile had a typo*

- The Python application is fairly simple. It shows health check(although hardcoded) to the client and logs the client's User-Agent, Request Method, Path Requested, and the Response the client got. It uses UV for package management and python interpreter versioning. The project dependencies are as usual in the [pyproject.toml](./application/pyproject.toml)

- As for the [Dockerfile](./Dockerfile), it uses a lightweight base image and instead of installing UV from the package manager, it installs it using the `COPY` command. Again, to make the image lighter.

- The CI is simple too. The [first job](./.github/workflows/deploy.yml#L9) sets up the build container and logs into Azure using the Service Principal credentials( which was created in [this line](./README.md#L15) ) And then logs into **Azure Container Registry** to build the image and push it. The [second job](./.github/workflows/deploy.yml#L31) finally deploys the container to Azure Container Apps.

- As per the [IaC](./main.tf#L90), the final deployed URL should be available in the build logs or for the admin, available in the, well.... logs(az-cli logs)

> **Notes:** Check your `secrets.tfvar` when using any command that involves provisioning or Terraform in general. Most of the time, it is authentication, so, be sure to check creds whether in GitHub secrets or check out your Azure Portal.

> **Note 2:** I had to join a subscription to Microsoft.app to apply [main.tf](./main.tf). Anyone seeing this can do the same by going to your **Subscriptions**(in Azure Portal) and then find and click your subscription(mine is Student for this case, yours might be different) and in the left side of the screen which lists different configuration, find **Resource Providers** under **Settings**

## Operational Lessons and Engineering Fixes:
> Note: I forgot the my train of thought and gave my `git log --graph` to Gemini. The following text is generated with human feedback and supervision by Gemini.
### 1. Ingress Target Port Alignment (Zero-Downtime Rollbacks)

* **The Issue:** The application was updated to listen internally on port `8080`, but the existing cloud infrastructure architecture was configured to route incoming edge traffic exclusively to port `80`.
* **The Resolution:** Observed Azure's automated rolling upgrade safety mechanism in action: it flagged the updated container version as unhealthy due to failing port check responses, stopped traffic from routing to it, and automatically preserved 100% of live traffic on the previous stable revision. Synchronized the architecture by applying the corrected target port update via Terraform to perfectly match the application code.

### 2. Multi-Tag Registry Optimization

* **The Issue:** Pushing container revisions labeled exclusively with a generic `:latest` tag introduces version tracing confusion and caching collision vulnerabilities across the deployment cluster.
* **The Resolution:** Restructured the pipeline build stage to multi-tag the image during the build process, assigning a mutable reference pointer (`:latest`) alongside an immutable tracking signature derived from the unique Git Commit SHA (`${{ github.sha }}`).

### 3. Subscription Level Resource Group Registrations

* **The Issue:** Initial execution of the Terraform script failed due to an unregistered microservice controller framework within the base subscription account.
* **The Resolution:** Resolved by navigating to the core subscription scope inside the Azure Portal, accessing the **Resource Providers** configurations under settings, and manually registering the `Microsoft.App` provider namespace.
