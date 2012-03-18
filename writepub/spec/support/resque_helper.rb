# encoding: utf-8
module ResqueHelper
  
  def expect_and_perform_queue(queue_name, size)
    ResqueSpec.queue_by_name(queue_name).size.should == size
    ResqueSpec.perform_all(queue_name)
    commit_database
  end
  
end