module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class Maintenance < Common
    # Public: This method is used to create maintenance in zabbix server
    #
    # conn - Zabbix connection object
    # 
    # Example
    # create_maintenance(conn, config_hash, jira_number)
    #
    # Returns maintenance-id if maintenance is created successfully
    # Raises error otherwise
    # Returns if host/group details is not found
    # Returns if maintenance window already exists
    def create_maintenance(conn, config_hash, jira_number)
      current_time = Time.now.to_i
      hostids_arr = []
      groupids_arr = []
      timeperiods = [
        {
          period: config_hash['duration'].to_i,
          start_date: current_time,
          timeperiod_type: 0
        }
      ]
      maintenance_name = jira_number+' maintenance window'

      host_details = host_details(conn, config_hash['host']) unless config_hash['host'].nil?

      hostgroup_details = hostgroup_details(conn, config_hash['hostgroup']) unless config_hash['hostgroup'].nil?

      maintenance_details = maintenance_details(conn, maintenance_name)

      return unless maintenance_details.empty?

      hostids_arr.push(host_details.first['hostid']) unless host_details.empty?

      groupids_arr.push(hostgroup_details.first['groupid']) unless hostgroup_details.empty?

      conn.query(
        method: 'maintenance.create',
        params: {
          name: maintenance_name,
          active_since: current_time,
          active_till: current_time + config_hash['duration'].to_i,
          groupids: groupids_arr,
          hostids: hostids_arr,
          timeperiods: timeperiods
        }
      )
    end

    # Public: This method is used to update maintenance in zabbix server
    #
    # conn - Zabbix connection object
    #
    # Example
    # update_maintenance(conn, config_hash, jira_number)
    #
    # Returns maintenance-id if maintenance is updated successfully
    # Raises error otherwise
    # Returns if host/group-details/maintenance window is not found
    def update_maintenance(conn, config_hash, jira_number)
      current_time = Time.now.to_i
      hostids_arr = []
      groupids_arr = []
      timeperiods = [
        {
          period: config_hash['duration'].to_i,
          start_date: current_time,
          timeperiod_type: 0
        }
      ]

      maintenance_name = jira_number+' maintenance window'

      host_details = host_details(conn, config_hash['host']) unless config_hash['host'].nil?

      hostgroup_details = hostgroup_details(conn, config_hash['hostgroup']) unless config_hash['hostgroup'].nil?

      maintenance_details = maintenance_details(conn, maintenance_name)

      return if maintenance_details.empty?
      hostids_arr.push(host_details.first['hostid']) unless host_details.empty?

      groupids_arr.push(hostgroup_details.first['groupid']) unless hostgroup_details.empty?

      conn.query(
        method: 'maintenance.update',
        params: {
          maintenanceid: maintenance_details.first['maintenanceid'],
          name: maintenance_name,
          active_since: current_time,
          active_till: current_time + config_hash['duration'].to_i,
          groupids: groupids_arr,
          hostids: hostids_arr,
          timeperiods: timeperiods
        }
      )
    end

    # Public: This method is used to delete maintenance in zabbix server
    #
    # conn - Zabbix connection object
    #
    # Example
    # delete_maintenance(conn, config_hash)
    #
    # Returns maintenance-id if maintenance is deleted successfully
    # Raises error otherwise
    # Returns if maintenance window is not found
    def delete_maintenance(conn, config_hash)
      maintenance_details = maintenance_details(conn, config_hash['name'])

      return if (maintenance_details.empty?)

      conn.query(
        method: 'maintenance.delete',
        params: [ maintenance_details.first['maintenanceid'] ]
      )
    end
  end
end
