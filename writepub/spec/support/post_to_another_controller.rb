# encoding: utf-8
def wrap_with_controller( new_controller )
  old_controller = @controller
  @controller = new_controller.new
  yield
  @controller = old_controller
end