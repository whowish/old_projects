# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Squeks_session',
  :secret      => 'f177da6ee93389a51641dbb3bc09180dafbfc20955b637798ab3f9bfb2401fe3e8152f555f4efc5526f5e6bc28af5b8e316be123f26b28d66d02716432844ac1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
