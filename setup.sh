#!/bin/bash

# Provisions and configures the OpenEduAnalytics base architecture, as well as the Contoso package.
if [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ]; then
    echo "This setup script will install the Open Edu Analytics base architecture."
    echo ""
    echo "Invoke this script like this:  "
    echo "    setup.sh <orgId>"
    echo "where orgId is the id for your organization (eg, CISD3). This value must be 12 characters or less (consider using an abbreviation) and must contain only letters and/or numbers."
    echo ""
    echo "By default, the Azure resources will be provisioned in  the East US location."
    echo "If you want to have the resources provisioned in an alternate location, invoke the script like this: "
    echo "    setup.sh <orgId> <location>"
    echo "where orgId is the id for your organization (eg, CISD3), and location is the abbreviation of the desired location (eg, eastus, westus, northeurope)."
    echo ""
    echo "By default, this script creates security groups and assigns access for those security groups. This requires you to have Global Admin rights in AAD."
    echo "You can opt to create a set of resources (eg, for a test env) without setting up the security groups like this:"
    echo "    setup.sh <orgId> <location> false"
    echo "where orgId is the id for your organization (eg, CISD3), and location is the abbreviation of the desired location (eg, eastus, westus, northeurope), and false specifies that security groups should not be attempted to be created0."
    exit 1
fi


org_id=$1
org_id_lowercase=${org_id,,}
location=$2
location=${location:-eastus}
include_groups=$3
include_groups=${include_groups,,}
include_groups=${include_groups:-true}


resource_group="EduAnalytics${org_id}"
synapse_workspace="syeduanalytics${org_id_lowercase}"

# The assumption here is that this script is in the base path of the OpenEduAnalytics project.
oea_path=$(dirname $(realpath $0))

# setup the base architecture
$oea_path/setup_base_architecture.sh $org_id $location $include_groups
# install the ContosoISD package
$oea_path/packages/ContosoISD/setup.sh $org_id

# Setup is complete. Provide a link for user to jump to synapse studio.
workspace_url=$(az synapse workspace show --name $synapse_workspace --resource-group $resource_group | jq -r '.connectivityEndpoints | .web')
echo "--> Setup of the test environment is complete."
echo "Click on this url to open your Synapse Workspace: $workspace_url"
