class NotifyTest
  @queue = :normal
  
  

  
  def self.perform(member)
    puts "#{member.username} Hello"
  end
end