class WebMetricsSwiper
  
  attr_accessor :recalculate_all
  
  def initialize(is_recalculate_all=false)
    @recalculate_all = is_recalculate_all
  end
  
  def get_month_ending(month,year)
    
    if month == 0
      month = 12 
      year = year - 1
    end
    
    if month == 13
      month = 1 
      year = year + 1
    end
    
    month_ending = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    if (year%4) == 0 and month == 2
      return 29
    else
      return month_ending[month-1]
    end
    
  end
  
  def perform
    Lock.generate("WebMetricsSwiper").synchronize {
      
      backward = 48 * 3600
    
      if @recalculate_all
        puts "Recalculate all"
        first = WebTrace.first(:order=>"time ASC",:limit=>1)
        
        if first and (Time.now - first.time + 32*86400) > backward
          backward = (Time.now - first.time + 32*86400).to_i
        end
      end
      
      puts "Backward for #{backward} seconds"
    
      now = Time.now.utc
      
      begin
        start_time = Time.utc(now.year,now.month,now.mday,now.hour,0,0,0) - 3600
        
        (0..(backward/3600)).each { |i|
        
          analyze_unique_user_hour(start_time)
          analyze_activity_hour(start_time)
          start_time = start_time - 3600
          
        }
      end
      
      begin
        start_day = Time.utc(now.year,now.month,now.mday,0,0,0,0) - 86400
        
        (0..(backward/86400)).each { |i|
          analyze_unique_user_day(start_day)
          start_day = start_day - 86400
        }
      end
      
      begin
        start_week = Time.utc(now.year,now.month,now.mday,0,0,0,0) - 86400*now.wday - 86400*7 
        
        (0..(backward/(86400*7))).each { |i|
          analyze_unique_user_week(start_week)
          start_week = start_week - 86400*7
        }
      end
      
      begin
        start_month = Time.utc(now.year,now.month,1,0,0,0,0) - get_month_ending(now.month-1,now.year)*86400
        
        (0..(backward/(86400*28))).each { |i|
          analyze_unique_user_month(start_month)
          
          prev_month = start_month - 86400
          start_month = Time.utc(prev_month.year,prev_month.month,1,0,0,0,0)
        }
      end
      
      
    }
  end
  
  def analyze_activity_hour(start_time)
    
    
    
    stop_time = start_time + 3600
    
    WebTrace.all(:select=>"controller,action",:group=>"controller,action",:conditions=>["time >= ? AND time < ?",start_time,stop_time]).each { |path|
      
      w = WebTraceActivityHour.first(:conditions=>{:date=>start_time.strftime("%Y-%m-%d"),:hour=>start_time.hour,:controller=>path.controller,:action=>path.action})
  
      next if w
      
      guest_activity_count = WebTrace.first(:select=>"COUNT(1) AS count",:conditions=>["time >= ? AND time < ? AND member_id IN (?) AND controller=? AND action=?",start_time,stop_time,["","0",0],path.controller,path.action])
      guest_count = WebTrace.first(:select=>"COUNT(DISTINCT unique_key) AS count",:conditions=>["time >= ? AND time < ? AND member_id IN (?) AND controller=? AND action=?",start_time,stop_time,["","0",0],path.controller,path.action])
      
      member_activity_count = WebTrace.first(:select=>"COUNT(1) AS count",:conditions=>["time >= ? AND time < ? AND NOT(member_id IN (?)) AND controller=? AND action=?",start_time,stop_time,["","0",0],path.controller,path.action])
      member_count = WebTrace.first(:select=>"COUNT(DISTINCT unique_key) AS count",:conditions=>["time >= ? AND time < ? AND NOT(member_id IN (?)) AND controller=? AND action=?",start_time,stop_time,["","0",0],path.controller,path.action])
      
      w = WebTraceActivityHour.new
      w.date = start_time
      w.hour = start_time.hour
      w.controller = path.controller
      w.action = path.action
      w.guest_activity_count = guest_activity_count.count
      w.guest_count = guest_count.count 
      w.member_activity_count = member_activity_count.count
      w.member_count = member_count.count
      w.save
    }
  end
  
  def get_unique_user_data(start_time,stop_time)
    
    
    unique_user = WebTrace.first(:select=>"COUNT(DISTINCT unique_key) AS count",:conditions=>["time >= ? AND time < ?",start_time,stop_time])
    unique_ip = WebTrace.first(:select=>"COUNT(DISTINCT ip_address) AS count",:conditions=>["time >= ? AND time < ?",start_time,stop_time])
    unique_member = WebTrace.first(:select=>"COUNT(DISTINCT member_id) AS count",:conditions=>["time >= ? AND time < ?",start_time,stop_time])


    return (unique_user.count rescue 0),(unique_ip.count rescue 0),(unique_member.count rescue 0)
  end
  
  def analyze_unique_user_month(start_time)
    w = WebTraceUniqueUserMonth.first(:conditions=>{:date=>start_time.strftime("%Y-%m-%d")})
  
    return if w
    
    unique_user_count,unique_ip_count,unique_member_count = get_unique_user_data(start_time,start_time + get_month_ending(start_time.month,start_time.year)*86400)
    
    w = WebTraceUniqueUserMonth.new
    w.date = start_time
    w.unique_user_count = unique_user_count
    w.unique_ip_count = unique_ip_count
    w.unique_member_count = unique_member_count
    w.save
  end
  
  def analyze_unique_user_week(start_time)
    w = WebTraceUniqueUserWeek.first(:conditions=>{:date=>start_time.strftime("%Y-%m-%d")})
  
    return if w
    
    unique_user_count,unique_ip_count,unique_member_count = get_unique_user_data(start_time,start_time + 86400*7)
    
    w = WebTraceUniqueUserWeek.new
    w.date = start_time
    w.unique_user_count = unique_user_count
    w.unique_ip_count = unique_ip_count
    w.unique_member_count = unique_member_count
    w.save
  end
  
  def analyze_unique_user_day(start_time)
    w = WebTraceUniqueUserDay.first(:conditions=>{:date=>start_time.strftime("%Y-%m-%d")})
  
    return if w
    
    unique_user_count,unique_ip_count,unique_member_count = get_unique_user_data(start_time,start_time + 86400)
    
    w = WebTraceUniqueUserDay.new
    w.date = start_time
    w.unique_user_count = unique_user_count
    w.unique_ip_count = unique_ip_count
    w.unique_member_count = unique_member_count
    w.save
  end
  
  def analyze_unique_user_hour(start_time)
    
    if WebTraceUniqueUserHour.first(:conditions=>{:date=>start_time.strftime("%Y-%m-%d"),:hour=>start_time.hour})
      return
    end
    
    unique_user_count,unique_ip_count,unique_member_count = get_unique_user_data(start_time,start_time + 3600)
    
    w = WebTraceUniqueUserHour.new
    w.date = start_time
    w.hour = start_time.hour
    w.unique_user_count = unique_user_count
    w.unique_ip_count = unique_ip_count
    w.unique_member_count = unique_member_count
    w.save
  end
end