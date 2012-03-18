class Lock < ActiveRecord::Base
  def lock

    self.save

    while true
      l = Lock.first(:conditions=>{:name=>name},:order=>"id ASC")
      break if l == nil or l.id == self.id
    end
  end

  def release
    ActiveRecord::Base.connection.execute("DELETE FROM locks WHERE name='#{name}' ORDER BY id ASC LIMIT 1")
  end

  def self.generate(*names)
    l = Lock.new
    l.name = Lock.generate_name(names)
    return l
  end

  def synchronize(&block)


    lock rescue (raise "Getting Lock #{name} timeout")

    begin
      block.call()
    rescue Exception=>e
      raise e
    ensure
      while true
        release rescue next
        break
      end
    end

  end

  private
  def self.generate_name(names)

    if names.kind_of?(Array)
      names.map{ |t| t.to_s}.join('--')
    else
      names
    end
  end
end

begin
  ActiveRecord::Schema.define do

    create_table "locks", :force => false do |t|
      t.string "name",     :null => false
    end

  end
rescue
  #do nothing
end

ActiveRecord::Base.connection.execute("DELETE FROM locks")

