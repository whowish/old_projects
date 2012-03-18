class FacebookLog
    include Mongoid::Document 
    
    field :url, :type=>String, :default=>""
    field :url_from_facebook, :type=>String, :default=>""
    field :params_from_facebook, :type=>String, :default=>""
    field :redirect_url, :type=>String, :default=>""
    field :code, :type=>String, :default=>""
    field :response, :type=>String, :default=>""
    field :response_body, :type=>String, :default=>""
    field :error, :type=>String, :default=>""
    field :created_date,:type=>Time
    
    before_create :set_created_time
    
    def set_created_time
      self.created_date = Time.now
    end
end