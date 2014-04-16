class MailConfig < ActiveRecord::Base
  attr_accessible :conference_name, :cc, :from, :domain, :info, :test_email
end
