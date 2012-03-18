class AgreeableEntity
    include Mongoid::Document
    
    field :content, :type=>String
    embedded_in :entity, :polymorphic => true
end



