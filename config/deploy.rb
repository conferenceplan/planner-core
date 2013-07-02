#
set :stages, %w(production staging sandbox boskone lonestartest smofcon lscprog lscstage eastercon)
set :default_stage, "staging"
set :application, "Planner"
#set :repository,  "https://conferenceplan.svn.sourceforge.net/svnroot/conferenceplan/PlannerPrototype"
set :repository,  "svn://svn.code.sf.net/p/conferenceplan/code/Planner"
set :deploy_to, "/opt/www"

require "capistrano/ext/multistage"
require "config/capistrano_database_yml"
require "config/capistrano_production_rb"
require "config/capistrano_config_yml"
require "config/capistrano_delayed_job_yml"

require "bundler/capistrano"

set :scm, :subversion
set :group, "www-data"
set :use_sudo, false

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
