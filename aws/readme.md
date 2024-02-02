
# AWS VPN Connections Script

## Overview

This script, `awsconnections.sh`, helps you manage AWS connections, such as VPNs.

## Prerequisites

- **Linux terminal or WSL:** The script is designed to run in a Linux environment.
- **AWS CLI (aws with sso):** Ensure you have the AWS CLI installed and configured.
- **AWS Profile, account ID and region:** You'll need access to the account and region where the relevant networking resources are set up.
- **Permissions:** Verify that you have the necessary permissions to view the AWS resources.

## Usage

1. **Clone or copy the script:**
   - If using Git, clone the repository containing the script.
   - Otherwise, copy the contents of the `awsconnections.sh` file.

2. **Customize the script:**
   - Open the script in a text editor.
   - Replace any variables with your actual AWS details.

3. **Make the script executable:**
   - Run the following command in your terminal:
     ```bash
     chmod +x awsconnections.sh
     ```

4. **Run the script:**
   - Execute the script using:
     ```bash
     ./awsconnections.sh
    
