class MemberForgetPassword
  include Mongoid::Document
  
  field :member_id, :type=>String
  field :created_date, :type => DateTime
  index [[:member_id, Mongo::DESCENDING ],
         [:_id, Mongo::DESCENDING ]]
  
  include UniqueIdentity
  
  
end