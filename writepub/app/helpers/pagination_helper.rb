# encoding: utf-8
module PaginationHelper
  
  # Arguments
  # selected_end_date => the end date of the selected block
  # days_per_block => The number of days per block
  # width_per_block => The width of a block
  # total_width => Total width of the container
  #
  # return data
  # :months => [ PaginationMonth ]
  # :units => [ PaginationUnit ]
  #
  def get_pagination_data(selected_end_date, current_page, days_per_block, width_per_block, total_width)
    
    total_blocks = (total_width / width_per_block).to_i
    
    today = to_days(Time.now)
    selected_end_day = to_days(selected_end_date)
    
    selected_end_day = adjust_selected_end_day(selected_end_day, today)
    start_end_day, end_end_day = calculate_boundaries(selected_end_day, today, total_blocks, days_per_block)

    page_data = PaginationData.new
    page_data.months = generate_months(start_end_day - days_per_block + 1, end_end_day)
    page_data.units = generate_units(start_end_day, end_end_day, selected_end_day, today, days_per_block)
    
    label_page(current_page, page_data.units)
    
    page_data.months.each { |m|
      m.width = calculate_width_of_month(m, days_per_block, width_per_block)
    }
    
    start_time = Time.at((start_end_day - days_per_block + 1) * 86400).utc
    page_data.left = - ((start_time.day - 1) * width_per_block / days_per_block).to_i;

    return page_data
    
  end
  
  @@months = ["มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภ่าคม", "มิถุนายน", "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤศจิกายน", "ธันวาคม"]
  def format_selected_date(date)
    return "#{date.day} #{@@months[date.month-1]} #{date.year}"
  end
  
  def format_month(date)
    
    
    return "#{@@months[date.month-1]}"
  end
  
  private
  
    
    def to_days(date)
      return (date.to_i / 86400).to_i
    end
  
    def adjust_selected_end_day(selected_end_day, today)
      return selected_end_day + (today - selected_end_day)%7
    end
    
    
    def calculate_boundaries(selected_end_day, today, total_blocks, days_per_block)
      
      start_end_day = selected_end_day - (days_per_block * ((total_blocks-1).to_f / 2.0).ceil.to_i)
      end_end_day = selected_end_day + (days_per_block * ((total_blocks-1).to_f / 2.0).to_i)
      
      if end_end_day > today
        end_end_day = today
      end
      
      return start_end_day, end_end_day
      
    end
    
    
    def generate_months(start_day, end_day)
      
      start_time = Time.at(start_day * 86400).utc
      end_time = Time.at(end_day * 86400).utc
      
      month = start_time.month
      year = start_time.year
      
      months = []
      
      while true
      
        m = PaginationMonth.new
        m.month = month
        m.year = year
        
        months.push(m)
        
        break if month == end_time.month and year == end_time.year
      
        month += 1
        
        if month == 13
          month = 1
          year += 1
        end
      end
      
      
      return months
      
    end
    

    def generate_units(start_end_day, end_end_day, selected_end_day, today, days_per_block)
      
      units = []
      
      number_of_blocks = ((end_end_day - start_end_day)/days_per_block).to_i + 1
      
      number_of_blocks.times { |i|
      
        start_block_day = start_end_day + i*days_per_block - (days_per_block - 1)
        end_block_day = start_end_day + i*days_per_block
      
        unit = PaginationUnit.new
        unit.is_selected = false
        unit.is_present = false
        
        if start_block_day  <= selected_end_day \
            and selected_end_day <= end_block_day
           unit.is_selected = true
        end
        
        if (today - (days_per_block - 1)) <= today \
            and today <= today
           unit.is_present = true
        end
  
        units.push(unit)
      }
      
      return units
      
    end

    
    def label_page(current_page, units)
      
      selected_index = -1
      units.each_index { |i|
        if units[i].is_selected == true
          selected_index = i
          break
        end
      }
      
      raise 'There is no selected unit' if selected_index == -1
       
      units.each_index { |i|
        units[i].page = current_page + selected_index - i
      }
      
  end
  
  def calculate_width_of_month(month_data, days_per_block, width_per_block)
    
    days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    day = days[month_data.month - 1]
    
    if month_data.month == 2 and (month_data.year%4) == 0
      day = 29
    end
    
    return (day.to_f * width_per_block / days_per_block).to_i
    
  end

    
end
