class TemporaryImage < ActiveRecord::Base
  include ThumbnailismHelper
  
  def perform
    delete_image(name);
    self.delete
  end
end