# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_CollegeSwap_session',
  :session_key => '_CollegeSwap_session',
  :secret      => 'e37255788e7f9bc57b092e50d8986856d2bff910b7747a1234967a3a1a357995da1d556cd86895eb49473ce96b3944a177b72724040ec2b7ab425f206873a536'
  
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
#ActionController::Base.session_store = :active_record_store
