#
set :deploy_to, "/opt/www/lonestartest"
set :user, "deployer"
set :rails_env, "lonestartest" 
server 'lonestartest.myconferenceplanning.org', :app, :web, :db, :primary => true
