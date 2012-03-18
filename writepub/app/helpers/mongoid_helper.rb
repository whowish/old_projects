module MongoidHelper
  
  def commit_database(fsync=true)
    if fsync
      Mongoid.database.command({:getlasterror => 1, :fsync=>true})
    else
      Mongoid.database.command({:getlasterror => 1})
    end
  end
  
  extend self
  
end