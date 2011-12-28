#
set :deploy_to, "/opt/www/sandbox"
set :user, "admin"
server 'sandbox.myconferenceplanning.org', :app, :web, :primary => true
