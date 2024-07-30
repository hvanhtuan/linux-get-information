# .NOTES
# Written by: Tuan, Ho Vu Anh
# Version: 1.0
# Change Log:
# v1.0, 30-Jul-2024, First release

#!/bin/bash

# Requires dnf-utils package
# sudo yum -y install dnf-utils

# Get the start time
START_TIME=$(date)

# Get username
USERNAME=$(whoami)

# Get hostname
HOSTNAME=$(hostname)

# Get primary IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Define the output file
OUTPUT_FILE="${IP_ADDRESS}_${HOSTNAME}.txt"

# Get the current time and save it to the output file
echo "Time to generate this information by $USERNAME: $START_TIME" > $OUTPUT_FILE

# Get general system information
echo -e "\n\n##### General System Information #####" >> $OUTPUT_FILE
echo "Hostname: $HOSTNAME" >> $OUTPUT_FILE
echo "Chassis: $(sudo dmidecode -s chassis-type)" >> $OUTPUT_FILE
echo "Machine ID: $(cat /etc/machine-id)" >> $OUTPUT_FILE
echo "Boot ID: $(cat /proc/sys/kernel/random/boot_id)" >> $OUTPUT_FILE
echo "Virtualization: $(systemd-detect-virt)" >> $OUTPUT_FILE
echo "Operating System: $(cat /etc/redhat-release)" >> $OUTPUT_FILE
echo "Kernel: $(uname -r)" >> $OUTPUT_FILE
echo "Architecture: $(uname -m)" >> $OUTPUT_FILE

# Get OS version
echo -e "\n\n##### Operating System Version #####" >> $OUTPUT_FILE
cat /etc/redhat-release >> $OUTPUT_FILE

# Get CPU information
echo -e "\n\n##### CPU Information #####" >> $OUTPUT_FILE
lscpu | grep 'Model name\|Architecture\|CPU(s)' >> $OUTPUT_FILE

# Get RAM information
echo -e "\n\n##### RAM Information #####" >> $OUTPUT_FILE
free -h >> $OUTPUT_FILE

# Get Disk information
echo -e "\n\n##### Disk Information #####" >> $OUTPUT_FILE
df -h >> $OUTPUT_FILE

# Get all network interfaces and their IP addresses, subnet masks, and default gateway
echo -e "\n\n##### Network Information #####" >> $OUTPUT_FILE
ip -4 addr show >> $OUTPUT_FILE
ip route show >> $OUTPUT_FILE

# List all running services
echo -e "\n\n##### Listing all running services #####" >> $OUTPUT_FILE
systemctl list-units --type=service --state=running >> $OUTPUT_FILE

# Extract the names of the running services
SERVICE_NAMES=$(systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}')

# Loop through each service and get package information
for SERVICE in $SERVICE_NAMES; do
    # Extract the package name from the service name
    PACKAGE_NAME=$(rpm -qf $(systemctl show -p FragmentPath $SERVICE | cut -d= -f2))
    
    # Display information about the package and append to the output file
    echo -e "\n\n----- Information about the package for service $SERVICE ($PACKAGE_NAME) -----" >> $OUTPUT_FILE
    rpm -qi $PACKAGE_NAME >> $OUTPUT_FILE
done

# Header for the table
printf "%-40s %-25s %-30s %-30s %-45s %-65s\n" "Name" "Version" "Release" "Architecture" "Source" "Description" >> $OUTPUT_FILE

# List all installed packages with specified columns
rpm -qa --queryformat '%{NAME} %{VERSION} %{RELEASE} %{ARCH} %{SOURCERPM} %{SUMMARY}\n' | while read -r line; do
    name=$(echo $line | awk '{print $1}')
    version=$(echo $line | awk '{print $2}')
    release=$(echo $line | awk '{print $3}')
    arch=$(echo $line | awk '{print $4}')
    source=$(echo $line | awk '{print $5}')
    description=$(echo $line | awk '{print $6}')
    printf "%-40s %-25s %-30s %-30s %-45s %-65s\n" "$name" "$version" "$release" "$arch" "$source" "$description" >> $OUTPUT_FILE
done

echo -e "\n\n***** THE END *****" >> $OUTPUT_FILE

# Notify the user
echo "The information has been saved to '$OUTPUT_FILE' in the same folder of this script."
