# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ecohealth_session',
  :secret      => '206a008347c67d112ad2fc7d42eb52b4adab58ca343a426f965a18feb0a4b1cb136afd0012d1e53e12b7f7b01fa9045558ab03194d39d1d32d477c06703dab07'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
