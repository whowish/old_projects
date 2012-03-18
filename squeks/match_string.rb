$KCODE = "UTF-8"

def highlight_censor(a,b)
    as = []
    bs = []
    
    as.push(' ')
    bs.push(' ')
    
    a.chars { |c| as.push(c)}
    b.chars { |c| bs.push(c)}
    
    as.push(' ')
    bs.push(' ')
    
    link = []
    d = []
    as.length.times { 
      row = []
      row_link = []
      bs.length.times { 
        row.push(10000000000000000) 
        row_link.push([-1,-1])
      }
      
      d.push(row)
      link.push(row_link)
    }
    
    # base case
    d[0][0] = 0
    d[0][0] = 1 if as[0] != bs[0]
    
    (as.length-1).times { |i|
      i += 1
      d[i][0] = i + 1 
    }
    
    (bs.length-1).times { |j| 
        j += 1
        d[0][j] = j + 1 
    }
    
    (as.length-1).times { |i|
      i += 1
      (bs.length-1).times { |j| 
        j += 1
        
        d[i][j] = d[i-1][j-1]  + ((as[i]==bs[j])?0:1);
        link[i][j] = [i-1,j-1]
        
        (0..j-2).each { |k|
          if (d[i-1][k]+(j-k)) <= d[i][j]
            d[i][j] = d[i-1][k]+(j-k)
            link[i][j] = [i-1,k]
          end
        }
        
        (0..i-2).each { |k|
          if (d[k][j-1]+(i-k)) <= d[i][j]
            d[i][j] = d[k][j-1]+(i-k)
            link[i][j] = [k,j-1]
          end
        }
      }
    }
    
    best_path = []
    a_part = []
    b_part = []
    
    best_path.push(link.last.last)
    
    i = link.last.last[0]
    j = link.last.last[1]
    
    a_part.unshift("")
    b_part.unshift("")
    
    (i+1..as.length-1).each { |x|
      a_part[0] += as[x]
    }
    
    (j+1..bs.length-1).each { |x|
      b_part[0] += bs[x]
    }
    
    while best_path.last[0] > -1
      previous_node = best_path.last
      next_node = link[best_path.last[0]][best_path.last[1]]
      best_path.push(next_node)
      
      a_part.unshift("")
      b_part.unshift("")
      
      (next_node[0]+1..previous_node[0]).each { |x|
        a_part[0] += as[x]
      }
      
      (next_node[1]+1..previous_node[1]).each { |x|
        b_part[0] += bs[x]
      }
      
    end
    
    # delete space at front and trail
    a_part[1] = (a_part[0] + a_part[1]).strip
    b_part[1] = (b_part[0] + b_part[1]).strip
    
    a_part[a_part.length-2] = (a_part[a_part.length-2] + a_part[a_part.length-1]).strip
    b_part[b_part.length-2] = (b_part[b_part.length-2] + b_part[b_part.length-1]).strip
    
    a_part.delete_at(a_part.length-1)
    a_part.delete_at(0)
    
    b_part.delete_at(b_part.length-1)
    b_part.delete_at(0)
    
    puts a_part.inspect
    puts b_part.inspect
    
    highlight = false
    b_part.length.times { |i| 
      if highlight == false and a_part[i] != b_part[i] and
          b_part[i] = "<admin>#{b_part[i]}"
          highlight = true
      elsif highlight == true and a_part[i] == b_part[i]
        b_part[i] = "</admin>#{b_part[i]}"
        highlight = false
      end
    }
    
    b_part.push("</admin>") if highlight == true
    
    
    return b_part.join("")
  end

  
  puts highlight_censor("คุณเป็นอะไร","มึงเป็นเหี้ยไร")
  #puts highlight_censor("deabqwdqwdczz","aqwfqwfwqbc")