class SupportController < ApplicationController

  before_filter :authenticate_support_user!  
  
  def index
    # redirect to the sites root
  end
end
