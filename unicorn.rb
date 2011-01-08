# set path to app that will be used to configure unicorn, 
# note the trailing slash in this example
@dir = "/var/www/shortr/"

worker_processes 1
working_directory @dir

preload_app true

timeout 30

# Specify path to socket unicorn listens to, 
# we will use this in our nginx.conf later
listen "#{@dir}unicorn.sock", :backlog => 64

# Set process id path
pid "#{@dir}unicorn.pid"

# Set log file paths
stderr_path "#{@dir}unicorn.stderr.log"
stdout_path "#{@dir}unicorn.stdout.log"