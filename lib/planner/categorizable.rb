require 'active_support/concern'

module Planner
  module Categorizable
    extend ActiveSupport::Concern

    #
    # name = t.category_names.create
    #
    module ClassMethods
      def categorized()
        has_many :categories, :dependent => :delete_all, :as => :categorized, :class_name => 'Category'

        has_many :category_names, :through => :categories 
        
        send(:define_method, 'update_categories') do |category_name_ids|
          cat_ids = categories.collect{|c| c.category_name_id }
          del_candidates = categories.to_a.keep_if{|c| !category_name_ids.include?(c.category_name_id.to_s) } # candidates for deletion
          add_candidates = category_name_ids.to_a.keep_if{|i| (i.to_i != 0)  && !cat_ids.include?(i.to_i) } # candidates to add
          del_candidates.each do |c|
            c.delete
          end
          add_candidates.each do |c|
            self.categories.create({category_name_id: c.to_i})
          end
          
          reload          
        end                  

        CategoryName._categorizable(self)
      end
      
      #
      # This allows for a one to many relationship .... from category back to the categorized
      #
      def _categorizable(categorizable_type)
        has_many  categorizable_type.name.demodulize.pluralize.downcase.to_sym, :through => :categories,
                  :source => :categorized,
                  :source_type => categorizable_type.name
      end
    end

  end
end

ActiveRecord::Base.send(:include, Planner::Categorizable)
