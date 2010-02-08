# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_PlannerPrototype_session',
  :secret      => '554164b08dbc43a2559f5820edf665436ada434089229f7fb625f31aca1a1d3013674535dd912df3f46be2884a4b926ebb7faae6b4c67b67962b73aa467b469a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
