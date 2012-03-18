class EmailRegistrationPending
  include Mongoid::Document
  
  field :email, :type=>String
  index :email, :unique=>true
  index [[:email, Mongo::DESCENDING ],
         [:_id, Mongo::DESCENDING ]]
  
  include UniqueIdentity
end