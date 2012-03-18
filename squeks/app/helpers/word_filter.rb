class WordFilter
  def self.get_forbidden_words(text)
    
    return [] if text == nil
    
    words = ForbiddenWord.all
    
    forbidden = []
    words.each { |w| 
      forbidden.push(w.word) if text.match(/#{w.word}/i)
    }
    
    return forbidden
  end
end