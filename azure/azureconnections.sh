#!/bin/bash

# List of subscriptions (replace with your subscription IDs)
subscription1=""
subscription2=""

# List of resource groups (replace with your resource group names)
resourceGroup1=""
resourceGroup2=""

# Get list of VPN connections
connections1=$(az network vpn-connection list --resource-group $resourceGroup1 --subscription $subscription1 --query '[].{Name:name, Type:connectionType, Location:location}')
connections2=$(az network vpn-connection list --resource-group $resourceGroup2 --subscription $subscription2 --query '[].{Name:name, Type:connectionType, Location:location}')

# Print table separator
tableseperator () {
printf "%-32s %-20s %-20s %-10s %s\n" "|------------------------------|" "|--------------|" "|--------------------|" "|--------------------|" "|-----------|"
}

# Print table header
printf "%-32s %-20s %-20s %-10s %s\n" "|Connection Name     |" "|Connection Type|" "|Location|" "|Resource Group|" "|ENV|"
tableseperator

# Loop through each connection
for connection in $(echo "$connections1" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${connection} | base64 --decode | jq -r ${1}
    }

    # Extract connection information
    name=$(_jq '.Name')
    type=$(_jq '.Type')
    location=$(_jq '.Location')

    # Print connection information
    printf "%-32s %-20s %-20s %-10s %s\n" "|$name|" "|$type|" "|$location|" "|$resourceGroup1|" "|NON-PROD|"

    tableseperator
done

for connection in $(echo "$connections2" | jq -r '.[] | @base64'); do
    _jq() {
        echo ${connection} | base64 --decode | jq -r ${1}
    }

    # Extract connection information
    name=$(_jq '.Name')
    type=$(_jq '.Type')
    location=$(_jq '.Location')

    # Print connection information
    printf "%-32s %-20s %-20s %-10s %s\n" "|$name|" "|$type|" "|$location|" "|$resourceGroup2|" "|PROD|"

    tableseperator

done
