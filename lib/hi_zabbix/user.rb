module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class User < Common
    # Public: This method is used to create user in zabbix server
    #
    # conn - Zabbix connection object
    # 
    # Example
    # create_user(conn, config_hash)
    #
    # Returns user-id if user is created successfully
    # Returns nil if group id doesnt exist or user already present in zabbix
    # Raises Zabbix API Error if unable to create user
    def create_user(conn, config_hash)
      puts "\n Select User Type\n 1. Zabbix User\n 2. Zabbix Admin\n 3. Zabbix Super Admin "
      option = $stdin.gets.to_i
      if ( (option.to_i.nil?) || (option.to_i > 3) || (option.to_i < 1) )
        puts 'Invalid option selection!'
        return nil
      else
        groupid = groupid(conn, config_hash['user_group'])

        return nil if ( groupid.nil? || !user_details(conn, config_hash['alias']).empty? )

        puts "Set/Enter password for #{config_hash['name']}"
        password = STDIN.noecho(&:gets).chomp
        conn.users.create(
          alias: config_hash['alias'],
          passwd: password,
          name: config_hash['name'],
          usrgrps: groupid,
          type: option.to_i
        )
      end
    end
  end
end
