#
# Capistrano script for RC1 version of the Planner using Rails 3.2.x
#
set :stages, %w(parctec) # production staging sandbox 
set :default_stage, "staging"

require "rvm/capistrano"
require "rvm/capistrano/gem_install_uninstall"

require "capistrano/ext/multistage"
# so that bundler is used
require "bundler/capistrano"

require "./config/capistrano_database_yml.rb"
require "./config/capistrano_production_rb"
require "./config/capistrano_config_yml.rb"
require "./config/capistrano_delayed_job_yml"

set :rvm_type, :system
set :bundle_dir, ''
set :bundle_flags, '--system --quiet'

set :application, "planner-rc1"

set :scm, :subversion
set :group, "www-data"
set :use_sudo, false

set :repository,  "svn://svn.code.sf.net/p/conferenceplan/code/branches/planner-rc1"
set :deploy_to, "/opt/www"

# For asset pipeline
set :normalize_asset_timestamps, false

# TODO - add in the code for Puma
# require 'puma/capistrano'
require 'capistrano-puma'

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end