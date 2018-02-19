
#!/bin/bash

export OS_USER_DOMAIN_NAME=northamerica.cerner.net
export OS_AUTH_URL=https://44.128.19.51:5000/v3
export OS_PROJECT_NAME=ETSINTEGRATION
 
echo -n 'Please enter your OpenStack username: '
read -r OS_USERNAME_INPUT
export OS_USERNAME=$OS_USERNAME_INPUT

echo -n 'Please enter your OpenStack Password: '
read -sr OS_PASSWORD_INPUT
echo
export OS_PASSWORD=$OS_PASSWORD_INPUT

echo -n 'Please enter your OpenStack key pair name: '
read -r OS_KEYNAME_INPUT
export OS_KEYNAME=$OS_KEYNAME_INPUT

echo -n 'Please enter the path to your OpenStack private key file: '
read -r OS_KEYPATH_INPUT
export OS_KEYPATH=$OS_KEYPATH_INPUT
