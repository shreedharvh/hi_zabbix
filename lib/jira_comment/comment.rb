require 'jira-ruby'
require 'yaml'
require File.expand_path('format', File.dirname(__FILE__))

# Public: Various methods used to post a comment on a jira
# All methods are instance methods and should be called on the object of JiraComment class
class JiraComment

  # Public: This method initializes the username, password and loads the config file 
  #
  # username - username to login to jira (String)
  # password - password to login to jira (String)
  # config_file - jira config file path (String)
  #
  # Example -
  # JiraComment.new('uname','pwd','config.yml')
  # => Returns a JiraComment object
  #
  # Returns nothing if config file is loaded
  # Raises RuntimeError if file does not exist
  def initialize(username, password, config_file)
    @uname = username
    @pwd = password
    raise "Config file #{config_file} not present" unless File.exist? config_file
    raise "Config file #{config_file} is empty" if File.zero? config_file
    @config = load_config(config_file)
  end

  # Public: This method loads and verifies jira config file. 
  #
  # file - jira config file path (String)
  #
  # Example -
  # obj.load_config('config.yml')
  # => {"jira_api_root"=>{"jira"=>"https://jira.cerner.com/", "jira2"=>"https://jira2.cerner.com/", "jira3"=>"https://jira3.cerner.com/"}}
  #
  # Returns config hash if all the parameters are non nil
  # Raises RuntimeError if any of the parameter is nil or api_root is invalid
  def load_config(file)
    config = YAML.load_file(file)
    config['jira_api_root'].each do |jira, api_root|
      raise "JIRA configuration for '#{jira}' api_root is nil" unless api_root
      raise "'#{jira}' api_root is invalid" unless valid_url_format?(api_root)
    end
    return config
  end

  # Public: This method determines if a url is in the proper format 
  #
  # url - The url to validate (String)
  #
  # Example -
  # obj.valid_url_format?('https://jira3.cerner.com')
  # => true
  #
  # Returns true if the url is in correct format or false otherwise
  def valid_url_format?(url)
    url =~ /\A#{URI::regexp(['https'])}\z/
  end

  # Public: This method creates a JIRA::client object 
  #
  # instance - jira instance (String)
  #
  # Example -
  #
  # obj.create_jira_object('https://jira3.cerner.com')
  # => Return a JIRA::Client object
  #
  # Returns a JIRA::Client object
  def create_jira_object(instance)
    options = {
      :username     => @uname,
      :password     => @pwd,
      :context_path => '',
      :auth_type    => :basic,
      :site         => instance
    }
    JIRA::Client.new(options)
  end

  # Public: This method returns the JIRA::client object in which the project resides
  #
  # instance - jira instance (String)
  #
  # Example -
  # obj.get_client('ETSDEV')
  # => Returns a JIRA::Client object referring to 'https://jira3.cerner.com'
  #
  # Returns JIRA::client object if project is found
  # Raises RuntimeError in case of unauthorized/socket/any other HTTP errors
  def get_client(queue)
    @config['jira_api_root'].each do |_, api_root|
      begin
        jira_client = create_jira_object(api_root)
        project = jira_client.Project.all
        return jira_client if project.any? { |q| q.key_value == queue }
      rescue JIRA::HTTPError, SocketError
        next
      end
    end
    raise 'Unable to identify the Project/Jira Queue. Please verify the jira queue and your credentials or Contact the jira system administrators in case the jira servers are down.'
  end

  # Public: Validates if given jira exists
  #
  # jira_no - The jira number to be validated (String)
  # client - Jira client object (JIRA::client)
  #
  # Example -
  # obj.jira_id('ETSDEV-3965')
  # => Returns an object of JIRA::Resource::Issue which has the details of ETSDEV-3965
  # obj.jira_id('ETSDEV-0')
  # => Returns false
  #
  # Returns an object of JIRA::Resource::Issue if the jira number given is valid
  # Returns nil when the given jira is invalid or empty
  def jira_id(jira_no, client)
    client.Issue.find(jira_no)
  rescue JIRA::HTTPError, StandardError
    return nil
  end

  # Public: This method posts a comment on the jira in the given format 
  #
  # jira_no - jira number (String)
  # input - message(string/table/list) to be commented on the jira (String/Hash)
  # format - comment message format (String)
  #
  # Example -
  # obj.comment('ETSDEV-3965','test','string')
  # => true
  #
  # Returns true if the comment was posted successfully or false otherwise
  # Raises error if the given jira number/format is invalid
  def comment(jira_no, input, format = 'string')
    client = get_client(jira_no.gsub(/[0-9-]/, ''))
    issue = jira_id(jira_no, client)
    raise "Invalid jira number #{jira_no}" unless issue

    result = ''
    case format
    when 'string'
      result.concat(input)
    when 'table'
      result.concat(JiraCommentFormat::table_format(input))
    when 'list'
      result.concat(JiraCommentFormat::list_format(input))
    when 'miscellaneous'
      result.concat(JiraCommentFormat::miscellaneous_format(input))
    else
      raise "Invalid comment format : '#{format}' specified"
    end

    raise 'Comment string is empty!' if result.empty?
    issue.comments.build.save({ 'body' => result })
  end
end