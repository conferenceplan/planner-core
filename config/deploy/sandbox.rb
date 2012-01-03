#
set :deploy_to, "/opt/www/sandbox"
set :user, "deployer"
set :rails_env, "sandbox" 
server 'sandbox.myconferenceplanning.org', :app, :web, :db, :primary => true
