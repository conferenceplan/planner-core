#
set :deploy_to, "/opt/www/wfc2014"
set :user, "deployer"
set :rails_env, "wfc2014" 
server '198.61.179.196', :app, :web, :db, :primary => true
