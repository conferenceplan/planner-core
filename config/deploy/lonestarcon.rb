#
set :deploy_to, "/opt/www/lonestarcon"
set :user, "hbalen"
set :rails_env, "lonestarcon" 
server '69.164.197.174', :app, :web, :db, :primary => true
