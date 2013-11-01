#
set :deploy_to, "/opt/www/boskone51"
set :user, "deployer"
set :rails_env, "boskone" 
server 'boskone.myconferenceplanning.org', :app, :web, :db, :primary => true
