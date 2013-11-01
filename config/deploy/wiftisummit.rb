#
set :deploy_to, "/opt/www/wiftisummit"
set :user, "deployer"
set :rails_env, "wiftisummit" 
server '198.61.179.196', :app, :web, :db, :primary => true
#server 'wiftisummit14.myconferenceplanning.org', :app, :web, :db, :primary => true
