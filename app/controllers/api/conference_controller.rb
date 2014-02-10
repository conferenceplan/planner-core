class Api::ConferenceController < ApplicationController
  def index
    # Return details about the conference
    @theme = MobileTheme.find :first
  end
  def show
    @scale = params[:scale].to_f
    @theme = MobileTheme.find :first
    @formats = Format.find :all
    @cloudinaryURI = Cloudinary::Utils.cloudinary_url('A').sub(/\/A/,'')
    @partition_val = @cloudinaryURI.sub(/http\:\/\/a[0-9]*\./,'')
  end
end
