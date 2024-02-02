#!/bin/bash
#Check VPN tunnels configured in your AWS account and region.

#Add your profile, account ID and region
AWS_PROFILE=""
AWS_ACCOUNT_ID=""
REGION=""

# Check if the AWS account ID matches the desired account ID
CURRENT_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text --profile "$AWS_PROFILE" 2>/dev/null)
    if [[ "$CURRENT_ACCOUNT_ID" == "$AWS_ACCOUNT_ID" ]]; then
        echo "Already logged in with the desired profile and account."
    else
    echo "Not logged in. Logging in now..."
    aws sso login --profile "$AWS_PROFILE" --region $REGION --no-verify
fi


# Fetch VPN connections from AWS CLI
vpn_connections=$(aws --profile $AWS_PROFILE ec2 describe-vpn-connections --region $REGION --output json)

# Check if vpn_connections is empty
if [[ -z $vpn_connections ]]; then
  echo "Error: Unable to fetch VPN connections. Please log into the AWS Networking account or ensure you have the necessary permissions."
  exit 1
fi


# Function to extract value from JSON
get_value() {
  local json=$1
  local key=$2
  echo "$json" | grep -oP "\"$key\": \"\K[^\"]+"
}

# Function to print grid line
print_grid_line() {
  printf "+----------------------+-----------------+----------------------+----------+-----------------+---------------------+---------------------+---------------------+\n"
}

# Print table header
print_grid_line
printf "| %-20s | %-15s | %-20s | %-8s | %-15s | %-19s | %-20s | %-20s |\n" "Connection name" "Tunnel number" "Outside IP address" "Status" "StatusMessage" "Connection type" "TransitGatewayId" "Environment"
print_grid_line

# Loop through VPN connections and print details
for connection in $(echo "$vpn_connections" | jq -r '.VpnConnections[] | @base64'); do
  _jq() {
    echo "$connection" | base64 --decode | jq -r "$1"
  }

  connection_name=$(_jq '.Tags[] | select(.Key=="Name") | .Value')
  tunnel_number=$(_jq '.VgwTelemetry | length')
  tunnel_statuses=$(_jq '.VgwTelemetry | map(.Status) | join(",")')
  tunnel_status_messages=$(_jq '.VgwTelemetry | map(.StatusMessage) | join(",")')
  outside_ip_addresses=$(_jq '.VgwTelemetry | map(.OutsideIpAddress) | join(",")')
  connection_type=$(_jq '.Type')
  TransitGatewayId=$(_jq '.TransitGatewayId')
  environment=$(_jq '.Tags[] | select(.Key=="environment") | .Value')

  if [ "$tunnel_number" -gt 0 ]; then
    for ((i = 0; i < tunnel_number; i++)); do
      tunnel_status=$(echo "$tunnel_statuses" | awk -F',' '{print $'$((i + 1))'}')
      tunnel_status_message=$(echo "$tunnel_status_messages" | awk -F',' '{print $'$((i + 1))'}')
      outside_ip_address=$(echo "$outside_ip_addresses" | awk -F',' '{print $'$((i + 1))'}')
      print_grid_line
      printf "| %-20s | %-15s | %-20s | %-8s | %-15s |%-20s | %-20s | %-20s |\n" "$connection_name" "$(($i + 1))" "$outside_ip_address" "$tunnel_status" "$tunnel_status_message" "$connection_type" "$TransitGatewayId" "$environment"
    done
  else
    print_grid_line
    printf "| %-20s | %-15s | %-20s | %-8s | %-15s |%-20s |%-20s |\n" "$connection_name" "" "" "" "" "$connection_type"
  fi
done

print_grid_line
