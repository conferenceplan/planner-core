require 'rails'

module ActionDispatch::Routing

  class Mapper
    def planner_resources(res, opts = {})
      resources res.to_s, :defaults => { :format => 'json' }
      get res.to_s + "/find_page/:idx", :to => (res.to_s + "#find_page"), :defaults => { :format => 'json' }
    end
    
    def planner_linked_resources(res, opts = {})
      get     res.to_s + "/find_page/:idx(/:linkedto_type/:linkedto_id)", :to => (res.to_s + "#find_page"), :defaults => { :format => 'json' }
      get     res.to_s + "(/:linkedto_type/:linkedto_id)",                :to => (res.to_s + "#index"),     :defaults => { :format => 'json' }
      post    res.to_s + "(/:linkedto_type/:linkedto_id)",                :to => (res.to_s + "#create"),    :defaults => { :format => 'json' }
      get     res.to_s + "/new(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#new"),       :defaults => { :format => 'json' }
      get     res.to_s + "/:id/edit(/:linkedto_type/:linkedto_id)",       :to => (res.to_s + "#edit"),      :defaults => { :format => 'json' }
      get     res.to_s + "/:id(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#show"),      :defaults => { :format => 'json' }
      put     res.to_s + "/:id(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#update"),    :defaults => { :format => 'json' }
      delete  res.to_s + "/:id(/:linkedto_type/:linkedto_id)",            :to => (res.to_s + "#destroy"),   :defaults => { :format => 'json' }
    end

    def planner_find_page(res, opts = {})
      get res.to_s + "/find_page/:idx", :to => (res.to_s + "#find_page"), :defaults => { :format => 'json' }
    end
  end

end

