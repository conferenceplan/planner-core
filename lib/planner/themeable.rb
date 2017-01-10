require 'active_support/concern'

module Planner
  module Themeable
    extend ActiveSupport::Concern

    #
    module ClassMethods
      def themed()
        has_many :themes, :dependent => :delete_all, :as => :themed, :class_name => 'Theme'

        has_many :theme_names, :through => :themes 
        
        send(:define_method, 'update_themes') do |theme_name_ids|
          theme_ids = themes.collect{|c| c.theme_name_id }
          del_candidates = themes.to_a.keep_if{|c| !theme_name_ids.include?(c.theme_name_id.to_s) } # candidates for deletion
          add_candidates = theme_name_ids.to_a.keep_if{|i| (i.to_i != 0)  && !theme_ids.include?(i.to_i) } # candidates to add
          del_candidates.each do |c|
            c.delete
          end
          add_candidates.each do |c|
            self.themes.create({theme_name_id: c.to_i})
          end
          
          reload          
        end                  

        ThemeName._themed(self)
      end
      
      #
      # This allows for a one to many relationship ....
      #
      def _themed(theme_type)
        has_many  theme_type.name.demodulize.pluralize.downcase.to_sym, :through => :themes,
                  :source => :themed,
                  :source_type => theme_type.name
      end
    end

  end
end

ActiveRecord::Base.send(:include, Planner::Themeable)
