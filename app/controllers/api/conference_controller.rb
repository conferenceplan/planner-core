class Api::ConferenceController < ApplicationController
  def index
    @mobilePages = MobilePage.find :all, :order => 'position asc'
    @scale = params[:scale].to_f
    @theme = MobileTheme.where('isdefault = ?', true).first
    @theme = MobileTheme.find :first if !@theme
    @logo = ConferenceLogo.find :first
    @formats = Format.find :all
    @default_bio_image = DefaultBioImage.find :first
    @cloudinaryURI = Cloudinary::Utils.cloudinary_url('A').sub(/\/A/,'')
    @partition_val = /upload/
  end
  
  def show
    @mobilePages = MobilePage.find :all, :order => 'position asc'
    @scale = params[:scale].to_f
    @theme = MobileTheme.where('isdefault = ?', true).first
    @theme = MobileTheme.find :first if !@theme
    @logo = ConferenceLogo.find :first
    @default_bio_image = DefaultBioImage.find :first
    @formats = Format.find :all
    @cloudinaryURI = Cloudinary::Utils.cloudinary_url('A').sub(/\/A/,'')
    @partition_val = /upload/
  end
end
