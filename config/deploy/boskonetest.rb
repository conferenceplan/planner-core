#
set :deploy_to, "/opt/www/planner"
set :user, "balen"
set :rails_env, "boskonetest" 

#ssh_options[:port] = 2223
#server '192.168.1.223', :app, :web, :db, :primary => true
server 'boskone.grenadine.co:2227', :app, :web, :db, :primary => true

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

