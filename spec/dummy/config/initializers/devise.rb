#
Devise.setup do |config|
  config.secret_key = ENV['devise_key']
  config.mailer_sender = 'support@grenadine.co' # will be over-ridden by mail config for conference
  require 'devise/orm/active_record'

  config.authentication_keys = [ :email ]
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10

  # A period that the user is allowed to confirm their account before their
  # token becomes invalid.
  config.confirm_within = 3.days

  # If true, requires any email changes to be confirmed (exactly the same way as
  # initial account confirmation) to be applied. Requires additional unconfirmed_email
  # db field (see migrations). Until confirmed, new email is stored in
  # unconfirmed_email column, and copied to email column on successful confirmation.
  config.reconfirmable = true

  # ==> Configuration for :validatable
  # Range for password length.
  config.password_length = 8..128

  # Email regex used to validate email formats. It simply asserts that
  # one (and only one) @ exists in the given string. This is mainly
  # to give user feedback and not to assert the e-mail validity.
  config.email_regexp = /\A[^@]+@[^@]+\z/

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity.
  config.timeout_in = 60.minutes

  # If true, expires auth token on session timeout.
  # config.expire_auth_token_on_timeout = false

  # ==> Configuration for :lockable
  # Defines which strategy will be used to lock an account.
  # :failed_attempts = Locks an account after a number of failed attempts to sign in.
  # :none            = No lock strategy. You should handle locking by yourself.
  # config.lock_strategy = :failed_attempts

  # Defines which key will be used when locking and unlocking an account
  # config.unlock_keys = [ :email ]

  # Defines which strategy will be used to unlock an account.
  # :email = Sends an unlock link to the user email
  # :time  = Re-enables login after a certain amount of time (see :unlock_in below)
  # :both  = Enables both strategies
  # :none  = No unlock strategy. You should handle unlocking by yourself.
  # config.unlock_strategy = :both

  # Number of authentication tries before locking an account if lock_strategy
  # is failed attempts.
  # config.maximum_attempts = 20

  # Time interval to unlock the account if :time is enabled as unlock_strategy.
  # config.unlock_in = 1.hour

  # Warn on the last attempt before the account is locked.
  # config.last_attempt_warning = false

  # ==> Configuration for :recoverable
  #
  # Defines which key will be used when recovering the password for an account
  # config.reset_password_keys = [ :email ]

  # Time interval you can reset your password with a reset password key.
  # Don't put a too small interval or your users won't have the time to
  # change their passwords.
  config.reset_password_within = 6.hours

  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

  # config.warden do |manager|
    # manager.failure_app = SiteLoginFailure
  # end
end
