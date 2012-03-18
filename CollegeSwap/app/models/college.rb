class College < ActiveRecord::Base
  
  validates_presence_of :name, :message => "Name must not be empty."

  STATUS_APPROVED = "APPROVED"
  STATUS_PENDING = "PENDING"

end