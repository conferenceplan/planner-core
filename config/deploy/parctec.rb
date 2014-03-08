#
set :deploy_to, "/opt/www/planner"
set :user, "deployer"
set :rails_env, "parctec"
set :use_new_relic, true

server 'demo.grenadine.co:2223', :app, :web, :db, :primary => true

after "deploy:finalize_update", "newrelic:symlink"

