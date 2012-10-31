#
set :deploy_to, "/opt/www/lonestarcon"
set :user, "progstaff"
set :rails_env, "lonestarcon" 
server 'vps.lonestarcon3.org', :app, :web, :db, :primary => true
