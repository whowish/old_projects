# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_friendmage_session',
  :secret      => '4d30dac0b80ff99c3cc1a120af19091611ef2671992826d19c22fa1b2524a89782e464b4d4465f9e7ca8784b0b873e3fc1e609f4c429e506209f627f12e2f6be'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
