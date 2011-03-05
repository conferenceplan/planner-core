class UserSession < Authlogic::Session::Base
  self.logout_on_timeout = true
end