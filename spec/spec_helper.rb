$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'hi_zabbix'

$FILE_LOG = HiZabbix.create_log(File.expand_path('RSPEC_HiZabbix_LOG.log'), Logger::DEBUG)
$STD_LOG = HiZabbix.create_log(nil, Logger::INFO)

def capture(stream)
  stream = stream.to_s
  eval "$#{stream} = StringIO.new"
  yield
  result = eval("$#{stream}").string
ensure
  eval("$#{stream} = #{stream.upcase}")
end

def parse(key, value)
  HiZabbix::Commands::Option.parse(key, value)
end

def option(name, options = {})
  @option ||= HiZabbix::Commands::Option.new(name, options)
end
