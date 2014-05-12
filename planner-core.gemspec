$:.push File.expand_path("../lib", __FILE__)

# Maintain your s.add_dependency's version:
require "planner_core/version"

# Describe your s.add_dependency and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "planner-core"
  s.version     = PlannerCore::VERSION
  s.authors     = ["Henry Balen", "Ruth Leibig", "Ian Stockdale", "Cathy Mullican", "Janice Gelb", "Terry Fong"]
  s.email       = ["info@grenadine.co"]
  s.licenses    = ["Apache"]
  s.homepage    = "http://www.myconferenceplanning.org"
  s.summary     = "Core for the planning system."
  s.description = "Core of the planning system."

  s.files       = Dir["{app,config,db,lib}/**/*"] + %w(LICENSE Rakefile)
  s.platform    = Gem::Platform::RUBY
  s.test_files  = Dir["test/**/*"]

  #
  #
  #
  s.add_dependency "rails", "~> 3.2.17"
  # s.add_dependency "jquery-rails"

  #
  s.add_dependency 'actionmailer' 
  s.add_dependency 'activerecord' 
  s.add_dependency 'axlsx_rails'
  s.add_dependency "audited-activerecord", "~> 3.0"
  s.add_dependency 'acts-as-taggable-on', "3.1.1"
  s.add_dependency 'devise'
  s.add_dependency 'scrypt'
  s.add_dependency 'bcrypt'
  s.add_dependency 'bluecloth'
  s.add_dependency 'bootstrap-sass', '~> 3.1'
  s.add_dependency 'cells'
  s.add_dependency 'ckeditor_rails'
  s.add_dependency "declarative_authorization" 
#  s.add_dependency 'authority'
  s.add_dependency 'deep_cloneable', '~> 1.6.0'
  s.add_dependency 'delayed_job' 
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'i18n' 
  s.add_dependency 'jbuilder'
  s.add_dependency 'jpbuilder'
  s.add_dependency 'mysql2' 
  s.add_dependency 'time_diff'
  s.add_dependency 'turbolinks'
  s.add_dependency 'will_paginate'
  s.add_dependency 'font_assets'
  s.add_dependency 'yajl-ruby'
  s.add_dependency 'log4r'
  s.add_dependency "browser"
  s.add_dependency 'jquery-rails', '2.2.1' # for 1.9.2 of jquery
  s.add_dependency 'jquery-ui-rails', '3.0.1'
  s.add_dependency 'momentjs-rails', '~> 2.5.0'
  s.add_dependency 'bootstrap3-datetimepicker-rails', '~> 2.1.30'
  s.add_dependency 'd3_rails'
  s.add_dependency 'jqgrid-jquery-rails', '~> 4.5.200'
  s.add_dependency 'prawn_rails'
  s.add_dependency "select2-rails"
  s.add_dependency "recaptcha"
  s.add_dependency 'carrierwave'
  s.add_dependency 'cloudinary'
  s.add_dependency 'dalli'
  s.add_dependency "connection_pool"
  s.add_dependency 'routing-filter'
  # These need to be define in the parent application!
  # s.add_dependency 'rack-jsonp'
  # s.add_dependency 'rack-jsonp-middleware' #, :require => 'rack/jsonp'
  s.add_dependency  'twitter-typeahead-rails'

end
