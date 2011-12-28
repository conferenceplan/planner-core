#
set :deploy_to, "/opt/www/sandbox"
server 'sandbox.myconferenceplanning.org', :app, :web, :primary => true
