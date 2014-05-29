Rails.configuration.middleware.use Browser::Middleware do
  # NewRelicPinger
  redirect_to "/upgrade.html" unless browser.modern? || browser.user_agent.include?('NewRelicPinger')
end
