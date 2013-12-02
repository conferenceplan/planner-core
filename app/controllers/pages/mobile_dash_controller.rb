class Pages::MobileDashController < ApplicationController
  def index
    @cellname = params[:cellname]
  end
end
