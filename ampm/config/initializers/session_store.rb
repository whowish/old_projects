# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Ampm_session',
  :secret      => 'b6ce484c37b398074de52c169611ec72fe213ec0bcb55c7daa4f8d281f0ad3748c12c4f3654d517a834a703794239c60dbfc0d8bf6a364e2e1d1c716ba886287'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
