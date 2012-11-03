#
set :deploy_to, "/opt/www/program"
set :user, "progstaff"
set :rails_env, "lscprog" 
server 'vps.lonestarcon3.org', :app, :web, :db, :primary => true
