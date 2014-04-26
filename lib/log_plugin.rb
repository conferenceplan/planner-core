#
#
#
require 'delayed_job'

class LogPlugin < Delayed::Plugin
    callbacks do |lifecycle|
        lifecycle.around(:invoke_job) do |job, *args, &block|
            begin
                Rails.application.config.logger = ActiveRecord::Base.logger = Logger.new(File.join(Rails.root, 'log', 'jobs.log'))
                # Forward the call to the next callback in the callback chain
                block.call(job, *args)
            rescue Exception => error
                # Make sure we propagate the failure!
                raise error
            end
        end
    end
end
