#
set :deploy_to, "/opt/www/smofcon"
set :user, "deployer"
set :rails_env, "smofcon" 
server 'smofcon.myconferenceplanning.org', :app, :web, :db, :primary => true
