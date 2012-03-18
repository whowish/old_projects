class TagController < ApplicationController
  
  # top tags (no incomings)
  def index
  end
 
  # show tag by params[:id]
  def show
    @tag = Tag.find(params[:id])
    
    if @tag.alias_with_tag == nil
      render :show
    else
      render :show_alias
    end
  end
  
  # params[:name] - the name of the new tag to be created
  def add
    entity = Tag.first(:conditions=>{:name=>params[:name].strip})
    
    if entity
      render :json=>{:ok=>false,:error_message=>"'#{params[:name]}' already exists."}
      return
    end
    
    entity = Tag.create(:name=>params[:name].strip)
    
    render :json=>{:ok=>true,:tag_id=>entity.id.to_s}
  end
  
  # params[:name] - the new name
  def edit
    current = Tag.find(params[:id])
    
    if !current
      render :json=>{:ok=>false,:error_message=>"The current tag becomes invalid. Please reload page."}
      return
    end
    
    current.name = params[:name].strip
    current.save
    
    render :json=>{:ok=>true,:tag_id=>current.id,:tag_name=>current.name}
  end
  
  # params[:child_name] and params[:id]
  def add_child
    current = Tag.find(params[:id])
    
    if !current
      render :json=>{:ok=>false,:error_message=>"The current tag becomes invalid. Please reload page."}
      return
    end
    
    child = Tag.find_or_create_by(:name=>params[:child_name].strip)

    if child.alias_with_tag != nil
      child = Tag.find(child.alias_with_tag)
    end
    
    
    if child.id == current.id
      render :json=>{:ok=>false,:error_message=>"The tag cannot be associated with itself."}
      return
    end
    
    
    current.add_to_set(:outgoings, child.id)
    child.add_to_set(:incomings,current.id)
    
    render :json=>{:ok=>true,:tag_id=>child.id,:tag_name=>child.name}
  end
  
  # params[:child_id] and params[:id]
  def remove_child
    
    current = Tag.find(params[:id])
    
    if !current
      render :json=>{:ok=>false,:error_message=>"The current tag becomes invalid. Please reload page."}
      return
    end
    
    child = Tag.find(params[:child_id])
    
    current.pull_all(:outgoings,[child.id])
    child.pull_all(:incomings,[current.id])
    
    Resque.enqueue(KratooTagUpdater, child.id)
    
    render :json=>{:ok=>true}
  end
  
  # params[:parent_name] and params[:id]
  def add_parent
    
    current = Tag.find(params[:id])
    
    if !current
      render :json=>{:ok=>false,:error_message=>"The current tag becomes invalid. Please reload page."}
      return
    end
    
    parent = Tag.find_or_create_by(:name=>params[:parent_name].strip)

    
    if parent.alias_with_tag != nil
      parent = Tag.find(parent.alias_with_tag)
    end
        
    if parent.id == current.id
      render :json=>{:ok=>false,:error_message=>"The tag cannot be associated with itself."}
      return
    end
    
    parent.add_to_set(:outgoings, current.id)
    current.add_to_set(:incomings, parent.id)
    
    Resque.enqueue(KratooTagUpdater, current.id)
    
    render :json=>{:ok=>true,:tag_id=>parent.id,:tag_name=>parent.name}
  end
  
  # params[:parent_id] and params[:id]
  def remove_parent
    
    current = Tag.find(params[:id])
    
    if !current
      render :json=>{:ok=>false,:error_message=>"The current tag becomes invalid. Please reload page."}
      return
    end
    
    parent = Tag.find(params[:parent_id])
    
    parent.pull_all(:outgoings,[current.id])
    current.pull_all(:incomings,[parent.id])
    
    Resque.enqueue(KratooTagUpdater, current.id)
    
    
    render :json=>{:ok=>true}
  end
  
  def delete
    current = Tag.find(params[:id])
    
    if !current
      render :json=>{:ok=>false,:error_message=>"The current tag becomes invalid. Please reload page."}
      return
    end
    
    Tag.any_of( :outgoings => current.id  ).any_of( :incomings => current.id  ).each { |tag|
      tag.pull_all(:incomings,[current.id])
      tag.pull_all(:outgoings,[current.id])
    }
    
    Tag.where( :alias_with_tag=> current.id  ).each { |tag|
      tag.destroy
    }
    
    current.destroy
    
    Resque.enqueue(KratooTagUpdater, current.id)
    
    render :json=>{:ok=>true}
  end
  
  # turn params[:id] to an alias of params[:target_name] and add its children and parents to ones of params[:target_id]
  def alias_with
    current = Tag.find(params[:id])
    target = Tag.first(:conditions=>{:name=>params[:target_name].strip})
    
    if current.alias_with_tag != nil
      render :json=>{:ok=>false,:error_message=>"You cannot perform a alias-with operation on an alias"}
      return
    end
    
    if !target
      render :json=>{:ok=>false,:error_message=>"The target tag '#{params[:target_name]}' does not exist."}
      return
    end
  
    if current.id == target.id
      render :json=>{:ok=>false,:error_message=>"The tag cannot be merged to itself."}
      return
    end
    
    Tag.any_of( :incomings => current.id  ).each { |tag| 
      tag.pull_all(:incomings,[current.id])
      
      next if tag.id == target.id
      tag.add_to_set(:incomings,target.id)
      target.add_to_set(:outgoings,tag.id)
    }
    
    Tag.any_of( :outgoings => current.id  ).each { |tag| 
      tag.pull_all(:outgoings,[current.id])
      
      next if tag.id == target.id
      tag.add_to_set(:outgoings,target.id)
      target.add_to_set(:incomings,tag.id)
    }
    
    current.update_attributes(:outgoings=> [], :incomings=>[],:alias_with_tag=>target.id)

    Resque.enqueue(KratooTagUpdater, current.id,target.id)
    
    render :json=>{:ok=>true,:tag_id=>target.id}
    
  end
  
 
  # destroy params[:id] and merge its children and parents to ones of params[:target_name]
  def merge
    current = Tag.find(params[:id])
    target = Tag.first(:conditions=>{:name=>params[:target_name].strip})
    
    if current.alias_with_tag != nil
      render :json=>{:ok=>false,:error_message=>"You cannot perform a merge operation on an alias"}
      return
    end
    
    if !target
      render :json=>{:ok=>false,:error_message=>"The target tag '#{params[:target_name]}' does not exist."}
      return
    end
  
    if current.id == target.id
      render :json=>{:ok=>false,:error_message=>"The tag cannot be merged to itself."}
      return
    end
    
    Tag.any_of( :incomings => current.id  ).each { |tag| 
      tag.pull_all(:incomings,[current.id])
      
      next if tag.id == target.id
      tag.add_to_set(:incomings,target.id)
      target.add_to_set(:outgoings,tag.id)
    }
    
    Tag.any_of( :outgoings => current.id  ).each { |tag| 
      tag.pull_all(:outgoings,[current.id])
      
      next if tag.id == target.id
      tag.add_to_set(:outgoings,target.id)
      target.add_to_set(:incomings,tag.id)
    }
    
    Tag.where( :alias_with_tag=> current.id  ).each { |tag|
      tag.alias_with_tag = target.id
    }
    
    current.destroy
    
    Resque.enqueue(KratooTagMerger, current.id,target.id)
    Resque.enqueue(KratooTagUpdater, current.id,target.id)
    
    render :json=>{:ok=>true,:tag_id=>target.id}
    
  end
  
  # params[:q]
  def autosuggest
    sunspot = Tag.search do
      fulltext "#{params[:q]}"
      order_by :score
    end

    keywords = []
    parent_ids = []
    sunspot.results.each { |row|
      next if row.id == params[:id]
      keywords.push({:id=>row.id,:name=>row.name,:parent_ids=>(row.incomings || [])})
      
      if row.incomings != nil
        parent_ids = parent_ids + row.incomings
      end
    }
    
    parent_ids.uniq!
    
    tag_hash = {}
    Tag.where(:_id.in => parent_ids).each { |tag|
      tag_hash[tag.id] = tag
    }
    
    keywords.each { |row|
    
      parent_names = []
      
      row[:parent_ids].each { |pid|
        parent_names.push(tag_hash[pid].name) if tag_hash[pid]
      }
    
      row[:parent_names] = parent_names.join(",")
    }
    
    render :json=>{:ok=>true,:results=>keywords}
  end

end
