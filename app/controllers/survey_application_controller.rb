class SurveyApplicationController < ApplicationController

  private
    def check_for_single_access_token 
      if params[:key] && !params[:key].empty?
        @respondent       = SurveyRespondent.find_by_single_access_token(params[:key]) 
        @current_respondent_session = SurveyRespondentSession.create!(@respondent) 
        begin
        self.smerf_user_id = @respondent.id
          rescue NoMethodError
        end
      
#        @respondent.reset_single_access_token! # do this if we want a new key every time
      end
    end 

end
