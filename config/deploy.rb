set :application, "PlannerPrototype"
set :repository,  "https://conferenceplan.svn.sourceforge.net/svnroot/conferenceplan/PlannerPrototype"
set :deploy_to, "/opt/www"

require "config/capistrano_database_yml"
require "config/capistrano_production_rb"

set :scm, :subversion

#set :user, "www-data"
set :use_sudo, false

role :web, "192.168.1.154"                          # Your HTTP server, Apache/etc
role :app, "192.168.1.154"                          # This may be the same as your `Web` server
role :db,  "192.168.1.154", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
