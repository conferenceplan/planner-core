class Api::ConferenceController < ApplicationController
  def index
    @scale = params[:scale].to_f
    @theme = MobileTheme.find :first
    @formats = Format.find :all
    @cloudinaryURI = Cloudinary::Utils.cloudinary_url('A').sub(/\/A/,'')
    @partition_val = @cloudinaryURI.sub(/http\:\/\/a[0-9]*\./,'')
  end
  
  def show
    @scale = params[:scale].to_f
    @theme = MobileTheme.find :first
    @formats = Format.find :all
    @cloudinaryURI = Cloudinary::Utils.cloudinary_url('A').sub(/\/A/,'')
    @partition_val = @cloudinaryURI.sub(/http\:\/\/a[0-9]*\./,'')
  end
end
