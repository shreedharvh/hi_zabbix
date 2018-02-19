module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class Hostgroup < Common
    # Public: This method is used to create hostgroup in zabbix server
    #
    # conn - Zabbix connection object
    # config_hash - contains commands inputs
    #
    # Example
    # create_host(conn, config_hash)
    #
    # Returns hostgroup-id if hostgroup is created successfully
    # Raises error otherwise
    def create_hostgroup(conn, config_hash)
      hostgroup_details = hostgroup_details(conn, config_hash['hostgroup'])
      if hostgroup_details.empty?
        conn.hostgroups.create(
          name: config_hash['hostgroup'] 
        )
      elsif hostgroup_details.first['name'].to_s == config_hash['hostgroup'].to_s
        return nil
      end
    end
  end
end
