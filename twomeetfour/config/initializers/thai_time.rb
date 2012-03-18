# encoding: utf-8
class Time
  
  MONTHS = ["มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน", "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"]
 
  def to_thai_date
      return "#{self.day} #{MONTHS[self.month-1]} #{(self.year+543)}"
  end
  
  def to_thai_time
      return "#{self.hour}:#{"%02d" % self.min} น."
  end
  
end