#
set :deploy_to, "/opt/www/boskone"
set :user, "deployer"
set :rails_env, "sandbox" 
server 'boskone.myconferenceplanning.org', :app, :web, :db, :primary => true
