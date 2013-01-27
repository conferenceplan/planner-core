
unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :deploy do

    namespace :siteconfig do

      desc <<-DESC
        Creates the siteconfig.yml configuration file in shared path.

        By default, this task uses a template unless a template \
        called siteconfig.yml.erb is found either is :template_dir \
        or /config/deploy folders.

      DESC
      task :setup, :except => { :no_release => true } do

        default_template = <<-EOF
#{stage}:
    :conference:
        :name: #{Capistrano::CLI.ui.ask("Enter name of the convention (ex: Loncon): ")}
        :email: #{Capistrano::CLI.ui.ask("Enter email address for program inquiries (ex: program@loncon.org): ")}
        :start_date: #{Capistrano::CLI.ui.ask("Enter start date and time (ex: 2012-02-17 00:00:00): ")}
        :number_of_days: #{Capistrano::CLI.ui.ask("Enter number of days: ")}
        EOF

        location = fetch(:template_dir, "config/deploy") + '/siteconfig.yml.erb'
        template = File.file?(location) ? File.read(location) : default_template

        config = ERB.new(template)

        run "mkdir -p #{shared_path}/config" 
        put config.result(binding), "#{shared_path}/config/siteconfig.yml"
      end

      desc <<-DESC
        [internal] Updates the symlink for siteconfig.yml file to the just deployed release.
      DESC
      task :symlink, :except => { :no_release => true } do
        run "ln -nfs #{shared_path}/config/siteconfig.yml #{release_path}/config/siteconfig.yml" 
      end

    end

    after "deploy:setup",           "deploy:siteconfig:setup"   unless fetch(:skip_db_setup, false)
    after "deploy:finalize_update", "deploy:siteconfig:symlink"
  end

end
