#!/bin/bash




decrypted_secrets=$(sops -d secrets.yaml)


ADMIN_USERNAME=$(echo "$decrypted_secrets" | grep admin_username | awk '{print $2}')
ADMIN_PASSWORD=$(echo "$decrypted_secrets" | grep admin_password | awk '{print $2}')
ADMIN_FIRSTNAME=$(echo "$decrypted_secrets" | grep admin_firstname | awk '{print $2}')
ADMIN_LASTNAME=$(echo "$decrypted_secrets" | grep admin_lastname | awk '{print $2}')
ADMIN_EMAIL=$(echo "$decrypted_secrets" | grep admin_email | awk '{print $2}')
JENKINS_LOCATION_URL=$(echo "$decrypted_secrets" | grep jenkins_location_url | awk '{print $2}')
DOMAIN=$(echo "$decrypted_secrets" | grep domain | awk '{print $2}')
NGINX_LINK=$(echo "$decrypted_secrets" | grep nginx_link | awk '{print $2}')
NGINX_CONF=$(echo "$decrypted_secrets" | grep nginx_conf | awk '{print $2}')

sed -i "s/ADMIN_USERNAME=\"\*\*\*\"/ADMIN_USERNAME=\"$ADMIN_USERNAME\"/" jenkins.sh
sed -i "s/ADMIN_PASSWORD=\"\*\*\*\"/ADMIN_PASSWORD=\"$ADMIN_PASSWORD\"/" jenkins.sh
sed -i "s/ADMIN_FIRSTNAME=\"\*\*\*\"/ADMIN_FIRSTNAME=\"$ADMIN_FIRSTNAME\"/" jenkins.sh
sed -i "s/ADMIN_LASTNAME=\"\*\*\*\"/ADMIN_LASTNAME=\"$ADMIN_LASTNAME\"/g" jenkins.sh
sed -i "s/ADMIN_EMAIL=\"\*\*\*\"/ADMIN_EMAIL=\"$ADMIN_EMAIL\"/" jenkins.sh
awk -v jenkins_location_url="$JENKINS_LOCATION_URL" '{gsub(/JENKINS_LOCATION_URL="[^"]*"/, "JENKINS_LOCATION_URL=\"" jenkins_location_url "\""); print}' jenkins.sh > jenkins.sh.tmp && mv jenkins.sh.tmp jenkins.sh
sed -i "s/JENKINS_LOCATION_URL=\"\*\*\*\"/JENKINS_LOCATION_URL=\"$JENKINS_LOCATION_URL\"/" jenkins.sh
sed -i "s/DOMAIN=\"\*\*\*\"/DOMAIN=\"$DOMAIN\"/" jenkins.sh
awk -v nginx_conf="$NGINX_CONF" '{gsub(/NGINX_CONF="[^"]*"/, "NGINX_CONF=\"" nginx_conf "\""); print}' jenkins.sh > jenkins.sh.tmp && mv jenkins.sh.tmp jenkins.sh
awk -v nginx_link="$NGINX_LINK" '{gsub(/NGINX_LINK="[^"]*"/, "NGINX_LINK=\"" nginx_link "\""); print}' jenkins.sh > jenkins.sh.tmp && mv jenkins.sh.tmp jenkins.sh
