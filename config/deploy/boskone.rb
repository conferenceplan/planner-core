#
set :deploy_to, "/opt/www/boskone"
server 'boskone.myconferenceplanning.org', :app, :web, :primary => true
