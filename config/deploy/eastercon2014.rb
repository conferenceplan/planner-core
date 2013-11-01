#
set :deploy_to, "/opt/www/eastercon2014"
set :user, "deployer"
set :rails_env, "eastercon2014" 
server '198.61.179.196', :app, :web, :db, :primary => true
