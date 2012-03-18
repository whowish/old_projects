@list = {"aaa"=>true,"bbb"=>true,"xx"=>true,"ccc"=>true}

def check_word(word)
  return @list[word]!=nil
end


word = "aaacccxxaaabbbccc"

t = []

word.chars {|c| t.push([])}

puts t.inspect

(0..(word.length-1)).each { |i|
  t[i][i] = check_word(word[i])
}

(1..word.length).each { |n|
  (0..(word.length-n-1)).each { |i|

    t[i][i+n] = false
    
    t[i][i+n] = true and  next if check_word(word[i..(i+n)])
    
    ((i+1)..(i+n-1)).each { |k|
      if t[i][i+k]==true and t[i+k+1][i+n]==true
        t[i][i+n] = true
        break
      end
    }
  }
}

puts t[0][word.length-1]
