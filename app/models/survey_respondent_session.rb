class SurveyRespondentSession < Authlogic::Session::Base
  params_key :key
  single_access_allowed_request_types :any
end
