require 'rails'

module ActionDispatch::Routing

  class Mapper
    def planner_resources(res, opts = {})
      resources res.to_s, :defaults => { :format => 'json' }
      get res.to_s + "/find_page/:idx", :to => (res.to_s + "#find_page"), :defaults => { :format => 'json' }
    end
    
    def planner_linked_resources(res, opts = {})
      get     res.to_s + "(/:linkedto_type/:linkedto_id)/find_page/:idx", :to => (res.to_s + "#find_page"), :defaults => { :format => 'json' }
      get     res.to_s + "(/:linkedto_type/:linkedto_id)",                :to => (res.to_s + "#index"),     :defaults => { :format => 'json' }
      post    res.to_s + "(/:linkedto_type/:linkedto_id)",                :to => (res.to_s + "#create"),    :defaults => { :format => 'json' }
      get     res.to_s + "/:id(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#show"),      :defaults => { :format => 'json' }
      put     res.to_s + "/:id(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#update"),    :defaults => { :format => 'json' }
      delete  res.to_s + "/:id(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#destroy"),   :defaults => { :format => 'json' }
    end

    def planner_nested_resources(res, linkedto_type, linkedto_id, opts = {})
      get     "/(:#{linkedto_type}/:#{linkedto_id}/)" + res.to_s + "/find_page/:idx", :to => (res.to_s + "#find_page"),     :defaults => { :format => 'json' }
      get     "/(:#{linkedto_type}/:#{linkedto_id}/)" + res.to_s,                :to => (res.to_s + "#index"),     :defaults => { :format => 'json' }
      post    "/(:#{linkedto_type}/:#{linkedto_id}/)" + res.to_s,                :to => (res.to_s + "#create"),    :defaults => { :format => 'json' }
      get     "/(:#{linkedto_type}/:#{linkedto_id}/)" + res.to_s + "/:id",       :to => (res.to_s + "#show"),      :defaults => { :format => 'json' }
      put     "/(:#{linkedto_type}/:#{linkedto_id}/)" + res.to_s + "/:id",       :to => (res.to_s + "#update"),    :defaults => { :format => 'json' }
      delete  "/(:#{linkedto_type}/:#{linkedto_id}/)" + res.to_s + "/:id",       :to => (res.to_s + "#destroy"),   :defaults => { :format => 'json' }
    end

    def planner_find_page(res, opts = {})
      get res.to_s + "/find_page/:idx", :to => (res.to_s + "#find_page"), :defaults => { :format => 'json' }
    end
  end

end
