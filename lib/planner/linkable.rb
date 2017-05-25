require 'active_support/concern'

module Planner
  module Linkable
    extend ActiveSupport::Concern
    
    class Configuration
        attr_accessor :linkedto_types
        attr_accessor :linkable_types
        
        def initialize
          @linkedto_types = []
          @linkable_types = []
        end
        
        def addLinked(c)
          linkedto_types << c
          linkedto_types.flatten!
        end
        
        def addLinkable(c)
          linkable_types << c
          linkable_types.flatten!
        end
    end
    
    def self.configure
      raise ArgumentError, "block not given" unless block_given?

      if ! defined? @@config
        @@config = Planner::Linkable::Configuration.new # TODO - change to test for existance first
      end

      yield config
    end

    def self.config
      @@config
    end
    
    def self.setup
      @@config.linkable_types.each do |linkable_type|
        if linkable_type.is_a? String
          clazz = Object.const_get linkable_type
          clazz.linked
        else
          linkable_type.linked
        end
      end
      @@config.linkedto_types.each do |linkedto_type|
        if linkedto_type.is_a? String
          clazz = Object.const_get linkedto_type
        else
          clazz = linkedto_type
        end
        clazz.linkable
        clazz.send(:define_method, 'before_links_destroy') do
          if defined? self._before_links_destroy
            _before_links_destroy
          end
        end
      end
    end
    
    #
    #
    #    
    # included do
      # # initialization to do once the module has been included
    # end

    #
    #
    #
    module ClassMethods
      #
      #
      #
      def linked(options = {})
        has_many  :linked, :as => :linkedto, :dependent => :destroy, :class_name => 'Link'

        Planner::Linkable.config.linkedto_types.each do |linkedto_type|
          if linkedto_type.is_a? String
            clazz = Object.const_get linkedto_type
          else
            clazz = linkedto_type
          end

          has_many clazz.name.demodulize.pluralize.underscore.to_sym, :through => :linked, :class_name => clazz.name  do
                      def category(c)
                        includes([:category_names]).references([:category_names]).where(['category_names.name = ?', c]).joins([:category_names])
                      end
                      def uncategorized
                        where(['categories.id is null']).includes([:categories]).references([:categories])
                      end
                    end
        end
      end
      
      #
      #
      #
      def linkable(options = {})
        before_destroy :before_links_destroy

        has_many  :links, :dependent => :destroy

        Planner::Linkable.config.linkable_types.each do |linkable_type|
          if linkable_type.is_a? String
            clazz = Object.const_get linkable_type
          else
            clazz = linkable_type
          end

          has_many  clazz.name.demodulize.pluralize.underscore.to_sym, :through => :links,
                    :source => :linkedto,
                    :source_type => clazz.name
        end
      end

    end

  end
end
