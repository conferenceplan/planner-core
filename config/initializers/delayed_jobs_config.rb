require 'log_plugin'

# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 30 # Change do that delayed job only checks every 30 secs instead of 5
#Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 10.minutes

# A 'plugin' that will help with directing the logging to a new file    
Delayed::Worker.plugins << LogPlugin
