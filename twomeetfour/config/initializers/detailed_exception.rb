class Exception

  def to_s_with_trace
      return "#{self.message}\n#{self.backtrace.join("\n")}"
  end
  
end