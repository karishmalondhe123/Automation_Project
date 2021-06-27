#!/bin/bash

# Variables
name="karishma"
s3_bucket="upgrad-karishma"

# update the ubuntu repositories before starting
apt update -y

# Check if apache2 is installed
if [[ apache2 != $(dpkg --get-selections apache2 | awk '{print $1}') ]]; then
	
	apt install apache2 -y
fi

# Ensure that apache2 service is running
running=$(systemctl status apache2 | grep active | awk '{print $3}' | tr -d '()')
if [[ running != ${running} ]]; then
	
	systemctl start apache2
fi

# Ensure apache2 Service is enabled 
enabled=$(systemctl is-enabled apache2 | grep "enabled")
if [[ enabled != ${enabled} ]]; then
	#statements
	systemctl enable apache2
fi

# Create the file name
timestamp=$(date '+%d%m%Y-%H%M%S')

# Create tar archive of apache2 access and error logs
cd /var/log/apache2
tar -cf /tmp/${name}-httpd-logs-${timestamp}.tar *.log

# copy logs to s3 bucket
if [[ -f /tmp/${name}-httpd-logs-${timestamp}.tar ]]; then
	#statements
	aws s3 cp /tmp/${name}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${name}-httpd-logs-${timestamp}.tar
fi


# Task 3 code
filepath="/var/www/html"
# Check if inventory file exists
if [[ ! -f ${filepath}/inventory.html ]]; then
	#statements
	echo -e 'Log Type\t-\tTime Created\t-\tType\t-\tSize' > ${filepath}/inventory.html
fi

# Insert the logs into the file
if [[ -f ${filepath}/inventory.html ]]; then
	#statements
    size=$(du -h /tmp/${name}-httpd-logs-${timestamp}.tar | awk '{print $1}')
	echo -e "httpd-logs\t-\t${timestamp}\t-\ttar\t-\t${size}" >> ${filepath}/inventory.html
fi

# Create a cron job that runs service every minute or everyday
if [[ ! -f /etc/cron.d/automation ]]; then
	#statements
	echo "* * * * * root /root/Automation_Project/automation.sh" >> /etc/cron.d/automation
fi

