module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class Host < Common
    # Public: This method is used to create host in zabbix server
    #
    # conn - Zabbix connection object
    # 
    # Example
    # create_host(conn)
    #
    # Returns host-id if host is created successfully
    # Raises error otherwise
    def create_host(conn, config_hash)
      host_details = host_details(conn, config_hash['host_name'])
      if host_details.empty?
        conn.hosts.create(
          host: config_hash['host_name'],
          interfaces: [
            {
              type: 1,
              main: 1,
              ip: config_hash['ip'],
              dns: '',
              port: '10050',
              useip: 1
            }
          ],
          name: 'some host name',
          groups: [ groupid: conn.hostgroups.get_id(name: config_hash['hostgroup']) ]
        )
      elsif host_details.first['name'] == config_hash['host_name']
        return nil
      end
    end
  end
end
