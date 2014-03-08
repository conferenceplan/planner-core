#
# Temp fix for stop and restart (state file not specified correctly)
#

Capistrano::Configuration.instance.load do

  namespace :newrelic do
    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml" 
    end
  end

end
