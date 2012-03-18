class Member < ActiveRecord::Base

  def set_facebook_cache(facebook_cache)
    @facebook_cache = facebook_cache

    self.name = @facebook_cache.name
    self.gender = @facebook_cache.gender

    self.save if !@facebook_cache.is_guest

  end

  def method_missing(symbol, *args)
    begin
      super.method_missing(symbol, *args)
    rescue
      begin
        @facebook_cache.send(symbol,*args)
      rescue Exception=>e
        raise e
      end
    end
  end

end