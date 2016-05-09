module I18n
  module Backend
    KeyValue.class_eval do
      def initialized?
        true
      end

    protected
      def translations
        trans = {}
        store.keys.delete_if{|k| k.include?("#")}.each do |k|
          trans_pointer = trans
          key_array = k.split(".")
          last_key = key_array.delete_at(key_array.length-1)
          key_array.each do |current|
            if !trans_pointer.has_key?(current.to_sym)
              trans_pointer[current.to_sym] = {}
            end
            trans_pointer = trans_pointer[current.to_sym]
          end
          trans_pointer[last_key.to_sym] = ActiveSupport::JSON.decode(store[k])
          
          #trans_pointer[last_key.to_sym] = store[k]
        end
        return trans
      end

      def init_translations
      end
    end
  end
end
