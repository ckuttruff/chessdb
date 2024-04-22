root = "#{Dir.getwd}"

bind "tcp://0.0.0.0:3000"
#bind "unix://#{root}/tmp/puma/socket"
pidfile "#{root}/tmp/puma/pid"
state_path "#{root}/tmp/puma/state"
rackup "#{root}/config.ru"

activate_control_app
