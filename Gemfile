source "https://rubygems.org"

gem 'actionmailer' 
gem 'activerecord' 
gem "audited-activerecord", "~> 3.0"
gem 'acts-as-taggable-on' 
gem 'authlogic'
gem 'bluecloth'
gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'bootswatch-rails'
gem 'cells'
gem "declarative_authorization" 
gem "daemons"
gem 'delayed_job' 
gem 'delayed_job_active_record'
#gem 'enumerations_mixin' # put in vendor plugin because it has to be updated to R3.2
gem 'i18n' 
gem 'jbuilder'
gem 'jquery-rails'
gem 'mysql2' 
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'rails', '~> 3.2.12'
gem 'time_diff'
gem 'turbolinks'
gem 'will_paginate'

gem "recaptcha", :require => "recaptcha/rails"

gem 'i18n-active_record',
      :git => 'git://github.com/svenfuchs/i18n-active_record.git',
      :require => 'i18n/active_record'

# For locale in the route
gem 'routing-filter'

#gem 'capistrano', '~> 3.0', require: false, group: :development
#gem 'capistrano-rails', require: false, group: :development
#gem 'capistrano-bundler', require: false, group: :development
gem 'capistrano', '2.15.5', require: false, group: :development
gem 'rvm-capistrano', '1.5.0', require: false, group: :development
gem 'capistrano-puma', '0.0.1', require: false, group: :development

#
# Needed for installs
#
gem "rack", "1.4.5"
gem 'rake' #, '0.8.7'
gem 'therubyracer', :platforms => :ruby
gem 'puma', :platforms => :ruby
#gem 'capistrano-puma', require: false

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'compass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
end

group :development do
  # bundler requires these gems in development
  # gem 'ruby-debug-ide'
end

group :test do
  # bundler requires these gems while running tests
end
