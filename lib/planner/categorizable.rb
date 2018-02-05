require 'active_support/concern'

module Planner
  module Categorizable
    extend ActiveSupport::Concern

    #
    # name = t.category_names.create
    #
    module ClassMethods
      def categorized
        has_many :categories,
                 dependent: :delete_all,
                 as: :categorized,
                 class_name: 'Category'

        has_many :category_names, through: :categories

        validates_associated :category_names, :categories

        send(:define_method, 'update_categories') do |name_ids|
          ids = name_ids.is_a?(String) ? name_ids.split(',') : name_ids

          self.category_name_ids = ids
          save!

          reload
        end

        CategoryName._categorizable(self)
      end

      #
      # This allows for a one to many relationship .... from category back
      # to the categorized
      #
      def _categorizable(categorizable_type)
        has_many categorizable_type.name.demodulize.pluralize.downcase.to_sym,
                 through: :categories,
                 source: :categorized,
                 source_type: categorizable_type.name
      end
    end
  end
end

ActiveRecord::Base.send(:include, Planner::Categorizable)
