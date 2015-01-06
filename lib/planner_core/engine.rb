#
#
#
require 'active_support/all'
require 'axlsx_rails'
require "audited-activerecord"
require 'acts-as-taggable-on'
require 'devise'
require 'bootstrap-sass'
require 'cells'
require 'ckeditor_rails'
#require "authority" 
require 'declarative_authorization'
require 'deep_cloneable'
require 'i18n' 
require 'jbuilder'
require 'jpbuilder'
require 'mysql2' 
require 'time_diff'
require 'turbolinks'
require 'will_paginate'
require 'font_assets'
require 'log4r'
require "browser"
require 'jquery-rails'
require 'jquery-ui-rails'
require 'momentjs-rails'
require 'bootstrap3-datetimepicker-rails'
require 'd3_rails'
require 'jqgrid-jquery-rails'
require 'prawn_rails'
require 'prawn/table'
require "select2-rails"
require "recaptcha/rails" # ????
require "recaptcha" 
require 'carrierwave'
require 'cloudinary'
require 'dalli'
require "connection_pool"
require "routing-filter"
require "twitter-typeahead-rails"
require "encoding_sampler"
require "figaro"
require "ranked-model"

module PlannerCore
  class Engine < ::Rails::Engine

    # Add the assets in the engine to those to be precompiled
    initializer :assets do |app|
      app.config.assets.precompile += %W(
        pages/*.js
        pages/*.css
        panels/*.js
        panels/*.css
        survey_respondents/*.js
        survey_respondents/*.css
        surveys/*.js
        surveys/*.css
        users/*.js
      )
    end

    config.to_prepare do
      Dir.glob(PlannerCore::Engine.config.paths["lib"].expanded[0] + "/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
      Dir.glob(PlannerCore::Engine.config.paths["lib"].expanded[0] + "/planner/controller_additions.rb").each do |c|
        require_dependency(c)
      end
    end

    # RAILS 3 mechanism so parent app use the migrations in this engine
    # see http://pivotallabs.com/leave-your-migrations-in-your-rails-engines/
    initializer :append_migrations do |app|
      # unless the engine is the multi-tenant planner_front
      unless (app.root.to_s.match root.to_s) || (app.engine_name == "planner_front_application")
        app.config.paths["db/migrate"] += config.paths["db/migrate"].expanded
      end
    end

    #
    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end
    
    #
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    initializer :before_initialize do
      ActionController::Base.send(:include, Planner::ControllerAdditions)
      Cell::Rails.send(:include, Planner::ControllerAdditions)
    end    
  end
end
