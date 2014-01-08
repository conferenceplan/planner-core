source "https://rubygems.org"

gem 'actionmailer' 
gem 'activerecord' 
gem 'enumerations_mixin', :git => 'git://github.com/balen/enumerations_mixin.git'

gem 'axlsx_rails'

gem "audited-activerecord", "~> 3.0"
gem 'acts-as-taggable-on', "2.4.1" 
gem 'authlogic'
gem 'bluecloth'
gem 'bootstrap-sass', '~> 3.0.3.0'
gem 'cells'
gem 'ckeditor_rails'
gem "declarative_authorization" 
gem 'deep_cloneable', '~> 1.6.0'
gem "daemons"
gem 'delayed_job' 
gem 'delayed_job_active_record'
gem 'i18n' 
gem 'jbuilder', '1.5.3'
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
      :tag => 'rails-3.0',
      :require => 'i18n/active_record'

# For locale in the route
gem 'routing-filter'

#gem 'capistrano', '~> 3.0', require: false, group: :development
#gem 'capistrano-rails', require: false, group: :development
#gem 'capistrano-bundler', require: false, group: :development
gem 'capistrano', '2.15.5', require: false, group: :development
gem 'rvm-capistrano', '1.5.0', require: false, group: :development
gem 'capistrano-puma', '0.0.1', require: false, group: :development

gem 'dalli'

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
