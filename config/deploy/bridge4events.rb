#
set :deploy_to, "/opt/www/planner"
set :user, "deployer"
set :rails_env, "bridge4events"
set :use_new_relic, true

server '192.168.5.116', :app, :web, :db, :primary => true

after "deploy:finalize_update", "newrelic:symlink"

