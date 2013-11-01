#
set :deploy_to, "/opt/www/fantastika2013"
set :user, "deployer"
set :rails_env, "fantastika2013" 
server '198.61.179.196', :app, :web, :db, :primary => true
