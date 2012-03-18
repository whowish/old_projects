#
# When a tag is searched, its outgoing tags is also pulled recursively.
# A tag graph might forms circles, and it is ok to be that way.
#
# Kratoo can contains AliasTag in its tags (for displaying purpose),
# but it cannot contains AliasTag in its all_tags (for searching purpose);
#
# This way an alias tag can be shown to suit individual's culture;
# Its semantics is still the same.
#
class Tag
  include Mongoid::Document
  
  field :name, :type=>String
  field :is_discoverable, :type=>Boolean, :default=>true
  field :incomings, :type=>Array, :default=>[]
  field :outgoings, :type=>Array, :default=>[]
  field :alias_with_tag, :type=>String, :default=>nil
  
  index :incomings
  index :outgoings
  index :name
  index :alias_with_tag
  
  include Sunspot::Mongoid
  searchable do
    text :name, :as => :name_as

  end
  
end