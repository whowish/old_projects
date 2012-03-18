
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => DOMAIN_NAME,
  :user_name            => 'ecohealthnet@gmail.com',
  :password             => 'ecohealth123',
  :authentication       => 'plain',
  :enable_starttls_auto => true  
}