authorization do
  role :Admin do
#    has_permission_on :authorization_rules, :to => :read
#    has_permission_on :authorization_usages, :to => :read
    has_permission_on :users_admin, :to => :manage
  end
end
