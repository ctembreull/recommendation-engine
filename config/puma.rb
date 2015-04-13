workers 2
threads 1,6

app_dir    = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

rack_env = ENV['RACK_ENV'] || "development"
environment rack_env

# Socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

on_worker_boot do
  # nothing yet
end
