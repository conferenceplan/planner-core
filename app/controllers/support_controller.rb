class SupportController < ApplicationController

  before_filter :authenticate_support_user!  
  
  def index
  end
end
