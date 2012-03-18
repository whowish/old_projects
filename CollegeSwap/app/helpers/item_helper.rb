module ItemHelper
  def get_suggest_item(user,suggest_items_count)
    wishes = Item.all(:conditions=>{:facebook_id=> user.facebook_id,:item_type=>Item::ITEM_TYPE_WISH,:status=>Item::STATUS_ACTIVE,:is_money=>0})
     
    wishes_keyword_all = []
    wishes.each do |wish|
      split_word = []
      split_word = wish.title.split(/[\s]+/)
      split_word.each do |s|
        wishes_keyword_all.push(s.downcase)
      end
    end
    
    wishes_keyword_all = wishes_keyword_all - ['a','an','the','1','2','3','4','5','6','7','8','9','0']
   
    hash_wish = {}
    hash_junk = {}
    wishes_keyword_all.each do |wish_keyword|
      hash_wish[wish_keyword] = 0 if !hash_wish[wish_keyword]
      hash_wish[wish_keyword] = hash_wish[wish_keyword] + 1
    end
    
    
    
    #wishes_keyword = (hash_wish.sort {|a,b| a[1]<=>b[1]}.map { |k,v| k})[0..filter_count]
    wishes_keyword = (hash_wish.sort {|a,b| a[1]<=>b[1]}.map { |k,v| k})
    
    sql_junk = ""
    sql_junk = "status = '"+Item::STATUS_ACTIVE+"' AND is_money = 0"
    sql_junk += " AND item_type = '"+Item::ITEM_TYPE_JUNK+"'"
    sql_junk += " AND facebook_id != '"+user.facebook_id+"'"
    
    sql_title_junk = ""
    wishes_keyword = wishes_keyword.collect {  |key|  "title LIKE "+Item.sanitize('%%'+key.to_s+'%%')}
    sql_title_junk = wishes_keyword.join(" or ")
    sql_junk += " AND (" + sql_title_junk + ")"
    
    return_suggest = Item.all(:conditions=>[sql_junk],:order => "rand()",:limit=>suggest_items_count)
   
    return return_suggest
  end
  
#  def get_suggest_item(user,suggest_items_count)
#    #filter_count = 5
#    wishes = Item.all(:conditions=>{:facebook_id=> user.facebook_id,:item_type=>Item::ITEM_TYPE_WISH,:is_money=>0})
#     
#    wishes_keyword_all = []
#    wishes.each do |wish|
#      split_word = []
#      split_word = wish.title.split(/[\s]+/)
#      split_word.each do |s|
#        wishes_keyword_all.push(s)
#      end
#    end
#   
#    hash_wish = {}
#    hash_junk = {}
#    wishes_keyword_all.each do |wish_keyword|
#      hash_wish[wish_keyword] = 0 if !hash_wish[wish_keyword]
#      hash_wish[wish_keyword] = hash_wish[wish_keyword] + 1
#    end
#    
#    
#    #wishes_keyword = (hash_wish.sort {|a,b| a[1]<=>b[1]}.map { |k,v| k})[0..filter_count]
#    wishes_keyword = (hash_wish.sort {|a,b| a[1]<=>b[1]}.map { |k,v| k})
#    
#    junks = Item.all(:conditions=>{:facebook_id=> user.facebook_id,:item_type=>Item::ITEM_TYPE_JUNK,:is_money=>0})
#    junks_keyword_all = []
#    junks.each do |junk|
#      split_word = []
#      split_word = junk.title.split(/[\s]+/)
#      split_word.each do |s|
#        junks_keyword_all.push(s)
#      end
#    end
#    
#    junks_keyword_all.each do |junk_keyword|
#      hash_junk[junk_keyword] = 0 if !hash_junk[junk_keyword]
#      hash_junk[junk_keyword] = hash_junk[junk_keyword] + 1
#    end
#    
#    junks_keyword = []
#    #junks_keyword = (hash_junk.sort {|a,b| a[1]<=>b[1]}.map { |k,v| k})[0..filter_count]
#    junks_keyword = (hash_junk.sort {|a,b| a[1]<=>b[1]}.map { |k,v| k})
#    sql_junk = ""
#    sql_junk = "status = '"+Item::STATUS_ACTIVE+"' AND is_money = 0"
#    sql_junk += " AND item_type = '"+Item::ITEM_TYPE_JUNK+"'"
#    sql_junk += " AND facebook_id != '"+user.facebook_id+"'"
#    
#    sql_title_junk = ""
#    wishes_keyword = wishes_keyword.collect {  |key|  "title LIKE '%%"+key.to_s+"%%'"}
#    sql_title_junk = wishes_keyword.join(" or ")
#    sql_junk += " AND (" + sql_title_junk + ")"
#    
#    junks_other = Item.all(:conditions=>[sql_junk])
#  
#    sql_title_wish = ""
#    junks_keyword = junks_keyword.collect {  |key_junk|  "title LIKE '%%"+key_junk.to_s+"%%'"}
#    sql_title_wish = junks_keyword.join(" or ")
#    
#    hash_fb_id = {}
#    return_suggest = []
#    junks_other.each do |j|
#      junk_owner_id = j.facebook_id
#      if !hash_fb_id[junk_owner_id]
#        hash_fb_id[junk_owner_id] = 'yes'
#      else
#        hash_fb_id[junk_owner_id] = 'no'
#      end
#    
#      if hash_fb_id[junk_owner_id] == 'yes'
#        sql_wish = ""
#        sql_wish = "status = '"+Item::STATUS_ACTIVE+"' AND is_money = 0"
#        sql_wish += " AND item_type = '"+Item::ITEM_TYPE_WISH+"'"
#        sql_wish += " AND facebook_id = '"+junk_owner_id+"'"
#        sql_wish += " AND (" + sql_title_wish + ")"
#        wishes_match = Item.all(:conditions=>[sql_wish])
#        return_suggest += wishes_match
#      end
#    end
#    
#    return return_suggest[0...suggest_items_count]
#  end
end


