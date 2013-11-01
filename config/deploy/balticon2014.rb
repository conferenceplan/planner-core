#
set :deploy_to, "/opt/www/balticon2014"
set :user, "deployer"
set :rails_env, "balticon2014" 
server '198.61.179.196', :app, :web, :db, :primary => true
