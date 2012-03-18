class VersioningKratoo < VersioningObject
  include Mongoid::Document
    
    field :kratoo_id, :type => String
    embeds_one :object_data,:class_name=>"Kratoo"
    index [
            [:kratoo_id, Mongo::DESCENDING ],
            [:created_date, Mongo::DESCENDING]
          ]
end