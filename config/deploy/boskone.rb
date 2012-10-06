#
set :deploy_to, "/opt/www/boskone"
set :user, "deployer"
set :rails_env, "boskone" 
server 'boskone.myconferenceplanning.org', :app, :web, :db, :primary => true
