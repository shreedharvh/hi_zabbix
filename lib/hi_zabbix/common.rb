module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class Common

    # Public: Method loads all the config file
    #
    # configfile - contains Zabbix server and operations details
    #
    # Example
    # initialize('config.yml')
    #
    # Returns object if config file is loaded
    # Raises RuntimeError if file does not exist
    def initialize(config)
      @conn_config = config
    end

    # Public: This method connects to Zabbix Instance
    #
    # Returns connection object if valid values are passed 
    # Raises error otherwise
    def zabbix_connection(user, pwd)
      raise 'Zabbix URL is invalid' unless (@conn_config['url'].match(/http[s]?:\/\/[\S]+/))
      connection ||= ZabbixApi.connect(
        url: @conn_config['url'],
        user: user,
        password: pwd
      )
      raise 'Connection Unsuccessful ' unless connection
      connection
    end

    # Public: Method checks hostgroups presence in zabbix
    #
    # hostgroups - contains names of hostgroups
    # conn - zabbix connection object
    #
    # Example
    # check_hostgroups(hostgroups,conn)
    #
    # Returns hash with names of hostgroup that are present and not-present
    # Raises RuntimeError if file does not exist
    def check_hostgroups(conn, hostgroups)
      hostgroup_presence = { present: [], not_present: [] }
      hostgroups.compact.each do |hostgroup|
        # check hostgroup presence in zabbix
        groupid = conn.hostgroups.get_id(name: hostgroup)
        groupid.nil? ? hostgroup_presence[:not_present].push(hostgroup) : hostgroup_presence[:present].push(hostgroup)
      end
      return hostgroup_presence
    end

    # Public: Method gets host information from zabbix
    #
    # conn - Zabbix connection object
    # host_name - contains host name
    #
    # Example
    # host_details(conn, host_name)
    #
    # Returns hash which contains host information
    # Returns empty array otherwise
    def host_details(conn, host_name)
      conn.query(
        method: 'host.get',
        params: {
          search: { name: host_name}
        }
      )
    end

    # Public: Method gets hostgroup information from zabbix
    #
    # conn - zabbix connection object
    # hostgroup_name - contains hostgroup name
    #
    # Example
    # hostgroup_details(conn, hostgroup_name)
    #
    # Returns hash which contains hostgroup information
    # Returns empty array otherwise
    def hostgroup_details(conn, hostgroup_name)
      conn.query(
        method: 'hostgroup.get',
        params: {
          search: { name: hostgroup_name}
        }
      )
    end

    # Public: Method gets usergroup information from zabbix
    #
    # conn - zabbix connection object
    # groupname - contains usergroup name
    #
    # Example
    # groupid(conn, grpname)
    #
    # Returns hash which contains usergroup information
    # Returns empty array otherwise
    def groupid(conn, grpname)
      conn.usergroups.get_id(
        name: grpname
      )
    end

    # Public: Method gets user details from zabbix
    #
    # conn - zabbix connection object
    # _alias - contains usergroup name
    #
    # Example
    # user_details(conn, _alias)
    #
    # Returns hash which contains user details
    # Returns empty array otherwise
    def user_details(conn, _alias)
      conn.users.get(
        alias: _alias
      )
    end

    # Public: Method gets maintenance window details from zabbix
    #
    # conn - zabbix connection object
    # maintenance_name - contains maintenance name
    #
    # Example
    # maintenance_details(conn, maintenance_name)
    #
    # Returns hash which contains maintenance window details
    # Returns empty array otherwise
    def maintenance_details(conn, maintenance_name)
      conn.query(
        method: 'maintenance.get',
        params: {
          filter: { name: maintenance_name }
        }
      )
    end
  end
end
