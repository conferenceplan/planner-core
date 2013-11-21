class Pages::CommunicationsDashController < ApplicationController
  def index
    @cellname = params[:cellname]
  end
end
