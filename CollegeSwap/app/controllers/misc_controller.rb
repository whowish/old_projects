class MiscController < ActionController::Base
  def test
    UserMailer.deliver_test
  end
end
