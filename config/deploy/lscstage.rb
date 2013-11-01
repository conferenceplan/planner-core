#
set :deploy_to, "/opt/www/program"
set :user, "progstaff"
set :rails_env, "lscstage" 
server 'staging.lonestarcon3.org', :app, :web, :db, :primary => true
