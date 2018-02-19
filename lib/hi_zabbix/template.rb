module HiZabbix
  # Public: Various commands for the user to interact with hi_zabbix.
  class Template < Common
    # Public: This method is used to upload a template to zabbix server
    #
    # Returns nothing if upload is successful
    # Raises error otherwise
    def template_upload(conn, templatefile)
      
      hostgroups = []
            
      # using nokogiri gem library function to parse xml to retrieve hostgroup names from templatefile  
      doc = Nokogiri::XML(File.open(templatefile))
      raise 'Nokogiri::XML::SyntaxError' unless doc
      doc.xpath('//templates/template/groups/group/name').each do |groupname|
        hostgroups.push(groupname.text.strip)
      end
      template = File.read(templatefile)

      hostgroup_presence = check_hostgroups(conn,hostgroups)

      # print non existing hostgroups and raise 
      unless hostgroup_presence[:not_present].empty?
        HiZabbix.log('Hostgroups Not Present in Zabbix', :bold)
        hostgroup_presence[:not_present].each do |hostgroup|
          HiZabbix.log(hostgroup,:BOTH)
        end
        raise "Above hostgroups are not present in zabbix, Template cannot be uploaded "
      end
     
      conn.configurations.import(
        format: 'xml',
        rules: {
          hosts: { createMissing: true, updateExisting: true },
          templates: { createMissing: true, updateExisting: true },
          items: { createMissing: true, updateExisting: true, deleteMissing: true },
          graphs: { createMissing: true, updateExisting: true, deleteMissing: true },
          applications: { createMissing: true, updateExisting: true, deleteMissing: true },
          discoveryRules: { createMissing: true, updateExisting: true, deleteMissing: true },
          groups: { createMissing: true },
          maps: { createMissing: true, updateExisting: true, deleteMissing: true },
          screens: { createMissing: true, updateExisting: true },
          templateScreens: { createMissing: true, updateExisting: true, deleteMissing: true },
          triggers: { createMissing: true, updateExisting: true, deleteMissing: true },
          valueMaps: { createMissing: true, updateExisting: true },
          images: { createMissing: true, updateExisting: true }
        },
        source: template
      )     
    end
  end
end
