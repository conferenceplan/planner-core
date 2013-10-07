#
set :deploy_to, "/opt/www/planner"
set :user, "deployer"
set :rails_env, "parctec" 

#ssh_options[:port] = 2223
server '192.168.1.215', :app, :web, :db, :primary => true
#server 'event1.simui.com:2223', :app, :web, :db, :primary => true
#server '192.168.7.124', :app, :web, :db, :primary => true

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

