Rails.configuration.middleware.use Browser::Middleware do
  redirect_to "/upgrade.html" unless browser.modern?
end
