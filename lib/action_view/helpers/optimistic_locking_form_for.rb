module ActionView
  module Helpers
    module OptimisticLockingFormFor
      
      def self.included(base)
        base.alias_method_chain :form_for, :optimistic_locking
      end
      
      def form_for_with_optimistic_locking(record_or_name_or_array, *args, &block)
        form_for_without_optimistic_locking(record_or_name_or_array, *args) do |form_with_locking|
          lock_form = form_with_locking.object &&
          form_with_locking.object.respond_to?(:locking_enabled?) &&
          form_with_locking.object.locking_enabled? &&
          !form_with_locking.object.new_record?
          if lock_form
            concat(content_tag(:div,
            form_with_locking.hidden_field(form_with_locking.object.class.locking_column),
                     :style => 'margin:0;padding:0;display:inline').html_safe)
          end
          yield form_with_locking
        end
      end
      
    end
  end
end
