# 
#

unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :mailer do

      desc <<-DESC
        Create the production.rb file
      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
config.threadsafe!
config.cache_classes = true
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
# ActionController::Base.cache_store = :mem_cache_store, "10.180.186.87"
# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :tls => true,
  :address => "",
  :user_name => "",
  :domain => "",
  :password => "",
  :authentication => :plain,
  :port => 587
}

config.time_zone = '#{Capistrano::CLI.ui.ask("Enter Application Timezone: ")}'

EOF

        location = fetch(:template_dir, "config/deploy") + '/#{stage}.rb.erb'
        template = File.file?(location) ? File.read(location) : default_template

        config = ERB.new(template)

        run "mkdir -p #{shared_path}/config/environments" 
        put config.result(binding), "#{shared_path}/config/environments/#{stage}.rb"
      end

      desc <<-DESC
        [internal] Updates the symlink for stage.rb file to the just deployed release.
      DESC
      
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/environments/#{stage}.rb #{release_path}/config/environments/#{stage}.rb" 
      end

    end

    after "deploy:setup",           "deploy:mailer:setup"   unless fetch(:skip_db_setup, false)
    after "deploy:finalize_update", "deploy:mailer:symlink"

  end

end
