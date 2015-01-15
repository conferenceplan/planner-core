require 'active_support/concern'

module Planner
  module Linkable
    extend ActiveSupport::Concern
    
    included do
      # initialisation to do once the module has been included
    end

    module ClassMethods
      
      def linked(options = {})
        # has_many  :links, :as => :linkedto, :dependent => :delete_all
        # has_many  :linkedfrom, :through => :links,
                  # :source => :linkedto,
                  # :source_type => self.class.name
      end
      
      def linkable(options = {})
        has_many  :links #, :as => :linkedto, :dependent => :delete_all
        # has_many  :linkedto, :through => :links, # Need to know the type
                  # :source => :linkedfrom,
                  # :source_type => self.class.name
        has_many  :people, :through => :links, # Need to know the type
                  :source => :linkedto,
                  :source_type => 'Person' #self.class.name
      end
      
      # TODO - we need a way to get the hetrogenous collection
      # has_many :xxxx uses reflection to do the instantiation???
      # need to check and put in a linkedto/linkedfrom collection ....
      
      # Conference, Person, Item, Room
      
    end

  end
end
