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
        linkable_type.linked
      end
      @@config.linkedto_types.each do |linkedto_type|
        linkedto_type.linkable
      end
    end
    
    #
    #
    #    
    included do
      # initialization to do once the module has been included
    end

    #
    #
    #
    module ClassMethods
      #
      #
      #
      def linked(options = {})
        has_many  :linked, :as => :linkedto, :dependent => :delete_all, :class_name => 'Link'

        Planner::Linkable.config.linkedto_types.each do |linkedto_type|
          # has_many ('linked_' + linkedto_type.name.demodulize.pluralize.downcase).to_sym, :through => :linked, :class_name => linkedto_type.name
          has_many linkedto_type.name.demodulize.pluralize.downcase.to_sym, :through => :linked, :class_name => linkedto_type.name
        end

      end
      
      #
      #
      #
      def linkable(options = {})
        has_many  :links, :dependent => :delete_all

        Planner::Linkable.config.linkable_types.each do |linkable_type|
          has_many  linkable_type.name.demodulize.pluralize.downcase.to_sym, :through => :links,
                    :source => :linkedto,
                    :source_type => linkable_type.name
        end
      end
      
    end

  end
end
