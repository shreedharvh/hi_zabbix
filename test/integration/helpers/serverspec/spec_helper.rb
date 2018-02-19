require 'serverspec'

set :backend, :exec
set :path, '/opt/chefdk/embedded/bin:/sbin:/usr/local/sbin:$PATH'
