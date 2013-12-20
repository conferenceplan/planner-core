class Api::ThemeController < ApplicationController
  def show
    @theme = MobileTheme.find :first
  end
end
