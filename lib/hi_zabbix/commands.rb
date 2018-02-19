module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class Commands < Thor

    # Public: This function will be used to upload template to zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix template_upload -c config.yml
    desc 'template_upload', 'upload template'
    method_option :conf_file_path, aliases: '-c', desc: 'Config (YML) file'
    method_option :templatefile, required: true, aliases: '-f', desc: 'template xml file'
    def template_upload

      prerequisites(options['conf_file_path'])

      template_file_path = File.expand_path(options['templatefile'])
      raise "File not found #{template_file_path}" unless File.exist?(template_file_path)
      raise 'File is empty, please provide a valid file.' if File.zero?(template_file_path)
      temp_config = YAML.load_file(template_file_path)

      template_obj = HiZabbix::Template.new(@config)
      conn = template_obj.zabbix_connection(@user_id, @password) 
      raise 'Unable to connect to zabbix' unless conn

      status = template_obj.template_upload(conn,template_file_path)

      unless status
        HiZabbix.log('Failed to upload the Template', :BOTH)
      else
        HiZabbix.log('Template uploaded sucessfully', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Template uploaded successfully')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to create host in zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix create_host -c config.yml
    desc 'create_host', 'create host'
    method_option :conf_file_path, aliases: '-c', desc: 'Config (YML) file'
    method_option :host_name, aliases: '-n', desc: 'Host name'
    method_option :hostgroup, aliases: '-g', desc: 'Hostgroup name'
    method_option :ip, aliases: '-a', desc: 'Host IP address'
    def create_host

      prerequisites(options['conf_file_path'])

      host_obj = HiZabbix::Host.new(@config)
      conn = host_obj.zabbix_connection(@user_id, @password)
      raise 'Unable to connect to zabbix' unless conn

      status = host_obj.create_host(conn, options)

      unless status
        HiZabbix.log('Host already exist.', :BOTH)
      else
        HiZabbix.log('Sucessfully created host.', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Successfully created host.')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to create hostgroup in zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix create_hostgroup -c config.yml
    desc 'create_hostgroup', 'create hostgroup'
    method_option :conf_file_path, aliases: '-c', desc: 'Config (YML) file'
    method_option :hostgroup, aliases: '-g', desc: 'Hostgroup name'
    def create_hostgroup

      prerequisites(options['conf_file_path'])

      hostgroup_obj = HiZabbix::Hostgroup.new(@config)
      conn = hostgroup_obj.zabbix_connection(@user_id, @password)
      raise 'Unable to connect to zabbix' unless conn

      status = hostgroup_obj.create_hostgroup(conn, options)

      unless status
        HiZabbix.log('Hostgroup already exist.', :BOTH)
      else
        HiZabbix.log('Sucessfully created hostgroup.', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Successfully created hostgroup.')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to create user in zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix create_user -c config.yml
    desc 'create_user', 'create user'
    method_option :conf_file_path, aliases: '-c', desc: 'Path to config (YML) file'
    method_option :name, required: true, aliases: '-n', desc: 'Username'
    method_option :alias, required: true, aliases: '-a', desc: 'Alias name (user ID)'
    method_option :user_group, required: true, aliases: '-g', desc: 'User group name to which user should be added'
    def create_user

      prerequisites(options['conf_file_path'])

      user_obj = HiZabbix::User.new(@config)
      conn = user_obj.zabbix_connection(@user_id, @password)
      raise 'Unable to connect to zabbix' unless conn

      status = user_obj.create_user(conn, options)

      unless status
        HiZabbix.log('Unable to create user/ User already exists.', :BOTH)
      else
        HiZabbix.log('Sucessfully created user.', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Successfully created user.')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to create maintenance window in zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix create_maintenance 
    desc 'create_maintenance', 'create maintenance window'
    method_option :host, aliases: '-h', desc: 'Host to be put in maintenance'
    method_option :hostgroup, aliases: '-g', desc: 'Hostgroup to which host belongs'
    method_option :duration, aliases: '-t', desc: 'Maintenance window time period'
    method_option :conf_file_path, aliases: '-c', desc: 'Path to config (YML) file'
    def create_maintenance
      options['duration'] = 3600 if options[:duration].nil?
      raise 'Either Host or Hostgroup is required' if (options['host'].nil? && options['hostgroup'].nil?)

      prerequisites(options['conf_file_path'])

      maint_obj = HiZabbix::Maintenance.new(@config)
      conn = maint_obj.zabbix_connection(@user_id, @password)
      raise 'Unable to connect to zabbix' unless conn
      status = maint_obj.create_maintenance(conn, options, @jira_number)

      unless status
        HiZabbix.log('Unable to create maintenance window/maintenance window is already exists.', :BOTH)
      else
        HiZabbix.log('Successfully created maintenance window.', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Successfully created maintenance window.')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to update maintenance window in zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix update_maintenance
    desc 'update_maintenance', 'update maintenance window'
    method_option :host, aliases: '-h', desc: 'Host to be put in maintenance'
    method_option :hostgroup, aliases: '-g', desc: 'Hostgroup to which host belongs'
    method_option :duration, aliases: '-t', desc: 'Maintenance window time period'
    method_option :conf_file_path, aliases: '-c', desc: 'Path to config (YML) file'
    def update_maintenance
      options[:duration] = 3600 if options[:duration].nil?
      raise 'Either Host or Hostgroup is required' if (options[:host].nil? && options[:hostgroup].nil?)

      prerequisites(options['conf_file_path'])

      maint_obj = HiZabbix::Maintenance.new(@config)
      conn = maint_obj.zabbix_connection(@user_id, @password)
      raise 'Unable to connect to zabbix' unless conn
      status = maint_obj.update_maintenance(conn, options, @jira_number)

      unless status
        HiZabbix.log('Unable to update maintenance window/maintenance window doesn\'t exists.', :BOTH)
      else
        HiZabbix.log('Successfully updated maintenance window.', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Successfully updated maintenance window.')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to delete maintenance window in zabbix server.
    #         It will log the response and handle any errors raised in the process.
    # Example: hi_zabbix delete_maintenance
    desc 'delete_maintenance', 'delete maintenance window'
    method_option :name, aliases: '-n', desc: 'Maintenance window name'
    method_option :conf_file_path, aliases: '-c', desc: 'Path to config (YML) file'
    def delete_maintenance

      raise 'Provide maintenance window name' if options['name'].nil?

      prerequisites(options['conf_file_path'])

      maint_obj = HiZabbix::Maintenance.new(@config)
      conn = maint_obj.zabbix_connection(@user_id, @password)
      raise 'Unable to connect to zabbix' unless conn

      status = maint_obj.delete_maintenance(conn, options)

      unless status
        HiZabbix.log('Unable to delete maintenance window/maintenance window doesn\'t exists.', :BOTH)
      else
        HiZabbix.log('Successfully deleted maintenance window.', :BOTH)
        HiZabbix.log('Posted status on JIRA', :BOTH) if @jira.comment(@config['jira_number'],'Successfully deleted maintenance window.')
      end
    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to perform the health check operation
    # Example: hi_zabbix health_check -c config.yml -h 'whoami' -n '127.0.0.1'
    desc 'health_check', 'Performs healthcheck on the nodes and posts the results on jira'
    method_option :conf_file_path, aliases: '-c', desc: 'Path to config (YML) file'
    method_option :health_check, required: true, aliases: '-h', desc: 'Healthcheck command'
    method_option :node, required: true, aliases: '-n', desc: 'Nodes addresses(IP)'
    def health_check
      raise "Invalid input. Please enter valid input" unless ( ( /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\Z/ =~ options['node']) && !options['health_check'].nil? )
      prerequisites(options['conf_file_path'])
      result = { 'title' => 'Health Check Version', 'columns' => [ 'Node', 'Version' ], 'rows' => [] }
      options['node'].split(',').each_with_index do |node, index|
        result['rows'][index] = []
        output = `#{options['health_check'] % { node: node }} 2>&1`
        raise "Failed to run health_check command - #{output}" unless $?.success?
        result['rows'][index].push(node, output.strip.gsub('"',''))
      end

      raise 'Failed to run health_check command' if result['rows'].nil? || result['rows'].flatten.empty?
      HiZabbix.log('Successfully performed the health check operation', :BOTH) 
      HiZabbix.log('Posted the Health Check version on the JIRA', :BOTH) if @jira.comment(@config['jira_number'],result,'table')

    rescue StandardError => error
      HiZabbix.log(error, :BOTH)
    end

    # Public: This function will be used to load config file.
    #         check if file exists.
    # config_file_path -  path where config file is placed
    # Example: prerequisites(config_file_path)
    # Returns config hash if file is loaded
    # Raises error if file is not found or invalid file is passed
    no_tasks do 
      def prerequisites(conf_file_path = nil)
        puts "file path:#{conf_file_path}" if conf_file_path.nil?
        if conf_file_path.nil?
          @config = YAML.load_file(File.expand_path('config.yml', File.dirname(__FILE__)))
        else
          raise "File not found #{conf_file_path}" unless File.exist? conf_file_path
          raise 'File is empty, please provide a valid file.' if File.zero? conf_file_path
          @config = YAML.load_file(conf_file_path)
        end
        puts 'Enter associate ID'
        @user_id = STDIN.gets.chomp
        raise 'Please provide associate ID' if @user_id.empty?
        puts "Enter network password for #{@user_id}"
        @password = STDIN.noecho(&:gets).chomp
        raise 'Please provide password' if @password.empty?
        puts 'Enter jira number'
        @jira_number = STDIN.gets.chomp
        @jira = JiraComment.new(@user_id, @password, conf_file_path)
      end
    end
  end
end
