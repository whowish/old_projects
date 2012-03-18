class BirthdayCalendar < ActiveRecord::Base
  STATUS_CREATING = "CREATING"
  STATUS_WAIT_FOR_PAYMENT = "WAIT_FOR_PAYMENT"
  STATUS_FINISHED = "FINISHED"
  
  MODE_ONE_PEOPLE = "ONE_PEOPLE"
  MODE_FOUR_PEOPLE = "FOUR_PEOPLE"
  
  before_save :calculate_height
  
  def calculate_height
    self.height = 0
  end
end