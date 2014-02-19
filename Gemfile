source "https://rubygems.org"

platform :rbx do
  gem "racc", "1.4.9"
  gem "rubysl"
  gem "rdoc"
  gem "test-unit"
end

gem 'actionmailer' 
gem 'activerecord' 
gem 'enumerations_mixin', :git => 'git://github.com/balen/enumerations_mixin.git'

gem 'axlsx_rails'

gem "audited-activerecord", "~> 3.0"
gem 'acts-as-taggable-on', "2.4.1" 
gem 'authlogic'
gem 'bluecloth'
gem 'bootstrap-sass', '~> 3.1'
gem 'cells'
gem 'ckeditor_rails'
gem "declarative_authorization" 
gem 'deep_cloneable', '~> 1.6.0'
gem "daemons"
gem 'delayed_job' 
gem 'delayed_job_active_record'
gem 'i18n' 
gem 'jbuilder', '1.5.3'
gem 'jpbuilder'
gem 'mysql2' 
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'rails', '~> 3.2.12'
gem 'time_diff'
gem 'turbolinks'
gem 'will_paginate'
gem 'font_assets'

gem 'jquery-rails', '2.2.1' # for 1.9.2 of jquery
gem 'jquery-ui-rails', '3.0.1'
gem 'momentjs-rails', '~> 2.5.0'
gem 'bootstrap3-datetimepicker-rails', '~> 2.1.20'
gem 'd3_rails'
gem 'jqgrid-jquery-rails', '~> 4.5.200'

gem 'prawn_rails'
gem "select2-rails"

gem "recaptcha", :require => "recaptcha/rails"

gem 'carrierwave'
gem 'cloudinary'

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
gem 'turbo-sprockets-rails3'

# Needed for the new asset pipeline
group :assets do
  gem 'sass-rails',   '>= 3.2'
  gem 'compass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
  gem 'yui-compressor'
end

group :development do
  # bundler requires these gems in development
  # gem 'ruby-debug-ide'
  gem 'seed_dump', '0.5.3'
end

group :test do
  # bundler requires these gems while running tests
end
