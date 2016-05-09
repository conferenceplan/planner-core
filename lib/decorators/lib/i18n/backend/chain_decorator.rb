module I18n
  module Backend
    Chain.class_eval do

      def initialized?
        backends.each do |backend|
          if !backend.instance_of? I18n::Backend::ActiveRecord
            return false if !backend.initialized?
          end
        end
        return true
      end

    protected

      def translations
        trans = {}
        backends.reverse.each do |backend| # reverse so that the top most will be merged-in
          if !backend.instance_of? I18n::Backend::ActiveRecord
            backend.instance_eval do
              trans.deep_merge!(translations)
            end
          end
        end
        return trans
      end

      def init_translations
        backends.each do |backend|
          if !backend.instance_of? I18n::Backend::ActiveRecord
            backend.instance_eval do
              init_translations
            end
          end
        end
      end
    end
  end
end
