# HiZabbix

This gem is a helpful command line tool to query and perform some of the time consuming tasks like creating Hosts, Hostgroups, Users and performing Maintenance operations. All of these Zabbix tasks can be completed easily, spending very little time.

## Installation


## Usage

You can perform various operations using the gem, `help` command provides you following list of commands with the description. 
```
hi_zabbix help
Commands:
  hi_zabbix create_host                                                                # create host
  hi_zabbix create_hostgroup                                                           # create hostgroup
  hi_zabbix create_maintenance                                                         # create maintenance window
  hi_zabbix create_user -a, --alias=ALIAS -g, --user-group=USER_GROUP -n, --name=NAME  # create user
  hi_zabbix delete_maintenance                                                         # delete maintenance window
  hi_zabbix health_check -h, --health-check=HEALTH_CHECK -n, --node=NODE               # Performs healthcheck on the nodes and posts the results on jira
  hi_zabbix help [COMMAND]                                                             # Describe available commands or one specific command
  hi_zabbix template_upload -f, --templatefile=TEMPLATEFILE                            # upload template
  hi_zabbix update_maintenance                                                         # update maintenance window
```
## Configuration File
#### Connection
```
url: '<zabbix API URL>'
conn_timeout: <optional>
timeout: 900
debug: 'true'
```

#### JIRA Config
```
jira_api_root:
  jira3: '<jira server url>'
jira_number: '<jiranumber with valid jira queue>'
```

### Create Host
Used to create a Host in Zabbix instance.
```
hi_zabbix help create_host
Usage:
  hi_zabbix create_host

Options:
  -c, [--conf-file-path=CONF_FILE_PATH]  # Config (YML) file
  -n, [--host-name=HOST_NAME]            # Host name
  -g, [--hostgroup=HOSTGROUP]            # Hostgroup name
  -a, [--ip=IP]                          # Host IP address

create host
```
### Create Hostgroup
Used to create a Host-group in Zabbix instance.
```
hi_zabbix help create_hostgroup
Usage:
  hi_zabbix create_hostgroup

Options:
  -c, [--conf-file-path=CONF_FILE_PATH]  # Config (YML) file
  -g, [--hostgroup=HOSTGROUP]            # Hostgroup name

create hostgroup
```
### Create User
Used to create different types of users, Zabbix User, Zabbix Admin & Zabbix Super Admin.
```
hi_zabbix help create_user
Usage:
  hi_zabbix create_user -a, --alias=ALIAS -g, --user-group=USER_GROUP -n, --name=NAME

Options:
  -c, [--conf-file-path=CONF_FILE_PATH]  # Path to config (YML) file
  -n, --name=NAME                        # Username
  -a, --alias=ALIAS                      # Alias name (user ID)
  -g, --user-group=USER_GROUP            # User group name to which user should be added

create user
```
### Upload Template
Used to upload a Zabbix Template.
```
hi_zabbix help template_upload
Usage:
  hi_zabbix template_upload -c, --configfile=CONFIGFILE -f, --templatefile=TEMPLATEFILE

Options:
  -c, --configfile=CONFIGFILE      # Config (YML/JSON) file
  -f, --templatefile=TEMPLATEFILE  # template xml file

upload template
```
### Create Maintenace Window
Used to create a Maintenace window.
```
hi_zabbix help create_maintenance
Usage:
  hi_zabbix create_maintenance

Options:
  -h, [--host=HOST]                      # Host to be put in maintenance
  -g, [--hostgroup=HOSTGROUP]            # Hostgroup to which host belongs
  -t, [--duration=DURATION]              # Maintenance window time period
  -c, [--conf-file-path=CONF_FILE_PATH]  # Path to config (YML) file

create maintenance window
```
### Delete Maintenance Window
Used to delete a Maintenace window.
```
hi_zabbix help delete_maintenance
Usage:
  hi_zabbix delete_maintenance

Options:
  -n, [--name=NAME]                      # Maintenance window name
  -c, [--conf-file-path=CONF_FILE_PATH]  # Path to config (YML) file

delete maintenance window
```
### Update Maintenance Window
Used to update a Maintenace window
```
hi_zabbix help update_maintenance
Usage:
  hi_zabbix update_maintenance

Options:
  -h, [--host=HOST]                      # Host to be put in maintenance
  -g, [--hostgroup=HOSTGROUP]            # Hostgroup to which host belongs
  -t, [--duration=DURATION]              # Maintenance window time period
  -c, [--conf-file-path=CONF_FILE_PATH]  # Path to config (YML) file

update maintenance window
```
### Health Check
Used to perform health check on the node, gets the latest code version.
```
hi_zabbix help health_check
Usage:
  hi_zabbix health_check -h, --health-check=HEALTH_CHECK -n, --node=NODE

Options:
  -c, [--conf-file-path=CONF_FILE_PATH]  # Path to config (YML) file
  -h, --health-check=HEALTH_CHECK        # Healthcheck command
  -n, --node=NODE                        # Nodes addresses(IP)

Performs healthcheck on the nodes and posts the results on jira
```
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shreedharvh/hi_zabbix.
