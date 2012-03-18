require 'spec_helper'

module TagControllerHelper
  def stay_the_same
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["A","B","C","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ ["A","C"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["A","B","C","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["A","C","E"]
  end
end

describe TagController do
  
  include TagControllerHelper  

  
  # Stub
  # Tag structure
  # -----------------
  #   _A__            Z
  #  |    |           |
  #  B____C___        X
  #     |    |
  #     D    E
  #
  #  F is an alias of E
  #  G is an alias of C
  #
  # Kratoo structure
  # ------------------
  # KA = [D F]
  # KB = [X]
  # KC = [C]
  # KD = [D]
  # KE = [E]
  #
  
  
  before(:each) do
    
    Tag.create_indexes
    Kratoo.create_indexes
    
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>["B","C"],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["D"],:incomings=>["A"])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>["D","E"],:incomings=>["A"])
    Tag.create(:_id=>"D",:name=>"D",:outgoings=>[],:incomings=>["B","C"])
    Tag.create(:_id=>"E",:name=>"E",:outgoings=>[],:incomings=>["C"])
    
    Tag.create(:_id=>"F",:name=>"F",:alias_with_tag=>"E")
    Tag.create(:_id=>"G",:name=>"G",:alias_with_tag=>"C")
    
    Tag.create(:_id=>"Z",:name=>"Z",:outgoings=>["X"],:incomings=>[])
    Tag.create(:_id=>"X",:name=>"X",:outgoings=>[],:incomings=>["Z"])
    
    
    
    @ka = Kratoo.create(:title=>"KA",:tag_ids=>["D","F"])
    @kb = Kratoo.create(:title=>"KB",:tag_ids=>["X"])
    @kc = Kratoo.create(:title=>"KC",:tag_ids=>["C"])
    @kd = Kratoo.create(:title=>"KD",:tag_ids=>["D"])
    @ke = Kratoo.create(:title=>"KE",:tag_ids=>["E"])
    
    @ka.organize_tags
    @kb.organize_tags
    @kc.organize_tags
    @kd.organize_tags
    @ke.organize_tags
    
  end


  it "add tag" do

    post :add, {:name=>"Y"}
   
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true

    
    post :add, {:name=>"LL"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
  end
  
  it "add new tag as parent" do
    post :add_parent, {:parent_name=>"Y",:id=>"A"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
    
    tag_id = body['tag_id']
    
    KratooTagUpdater.should have_queue_size_of(1)
    ResqueSpec.perform_all(:normal)
    
    Tag.find("A").incomings.should =~ [tag_id]
    Tag.find(tag_id).outgoings.should =~  ["A"]
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ [tag_id,"A","B","C","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ [tag_id,"A","C"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ [tag_id,"A","B","C","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ [tag_id,"A","C","E"]
  end
  
 it "add new tag as child" do
    post :add_child, {:child_name=>"Y",:id=>"A"}

    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_true
    
    tag_id = body['tag_id']
    
    Tag.find("A").outgoings.should =~ ["B","C",tag_id]
    Tag.find(tag_id).incomings.should =~ ["A"]
    
    stay_the_same
  end
  
  it "add parent" do
    post :add_parent, {:parent_name=>"X",:id=>"A"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
    
    KratooTagUpdater.should have_queue_size_of(1)
    ResqueSpec.perform_all(:normal)
    
    Tag.find("A").incomings.should =~ ["X"]
    Tag.find("X").outgoings.should =~ ["A"]
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["Z","X","A","B","C","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ ["Z","X","A","C"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["Z","X","A","B","C","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["Z","X","A","C","E"]
  end

  it "add child" do
    post :add_child, {:child_name=>"Z",:id=>"A"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_true
    
    Tag.find("A").outgoings =~ ["B","C","Z"]
    Tag.find("Z").incomings =~ ["A"]
    
    stay_the_same
  end
  
  it "add itself as parent, and it should fail" do
    post :add_parent, {:parent_name=>"A",:id=>"A"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)
    
    body.should include('ok')
    body['ok'].should be_false
    
    a = Tag.find("A")
    a.outgoings.should =~ ["B","C"]
    a.incomings.should =~ []
    
    stay_the_same
  end
  
  it "add itself as child, and it should fail" do
    post :add_child, {:child_name=>"A",:id=>"A"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_false
    
    a = Tag.find("A")
    a.outgoings.should =~ ["B","C"]
    a.incomings.should =~ []
    
    stay_the_same
  end
  
  it "make alias" do
    post :alias_with, {:target_name=>"X",:id=>"C"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_true
    
    KratooTagUpdater.should have_queue_size_of(1)
    ResqueSpec.perform_all(:normal)
    
    c = Tag.find("C")
    c.outgoings.should =~ []
    c.incomings.should =~ []
    (c.alias_with_tag == "X").should be_true
    
    x = Tag.find("X")
    x.outgoings.should =~ ["D","E"]
    x.incomings.should =~ ["Z","A"]
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["Z","A","B","X","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["A","Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ ["Z","A","X"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["Z","A","B","X","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["Z","A","X","E"]
  end
  
  it "merge" do
    post :merge, {:target_name=>"X",:id=>"C"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_true
    
    KratooTagUpdater.should have_queue_size_of(2)
    ResqueSpec.perform_all(:normal)
    
    c = Tag.first(:conditions=>{:_id=>"C"})
    c.should be_nil
    
    x = Tag.find("X")
    x.outgoings.should =~ ["D","E"]
    x.incomings.should =~ ["Z","A"]
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["Z","A","B","X","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["A","Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ ["Z","A","X"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["Z","A","B","X","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["Z","A","X","E"]
    
   
    Kratoo.find(@kc.id).tag_ids.should =~ ["X"]
  end
  
  it "delete tag" do
    post :delete, {:id=>"C"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_true
    
    KratooTagUpdater.should have_queue_size_of(1)
    ResqueSpec.perform_all(:normal)
    
    Tag.find("D").incomings.should =~ ["B"]
    Tag.find("E").incomings.should =~ []
    
    Tag.find("A").outgoings.should =~ ["B"]
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["A","B","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ []
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["A","B","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["E"]
    
    Kratoo.find(@kc.id).tag_ids.should =~ []
  end
  
  it "remove parent" do
    post :remove_parent, {:id=>"C",:parent_id=>"A"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_true
    
    KratooTagUpdater.should have_queue_size_of(1)
    ResqueSpec.perform_all(:normal)
    
    Tag.find("A").outgoings.should =~ ["B"]
    Tag.find("C").incomings.should =~ []
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["A","B","C","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ ["C"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["A","B","C","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["C","E"]
  end
  
  it "remove child" do
    post :remove_child, {:id=>"A",:child_id=>"C"}
    
    response.should be_success
    body = ActiveSupport::JSON.decode(response.body)

    body.should include('ok')
    body['ok'].should be_true
    
    KratooTagUpdater.should have_queue_size_of(1)
    ResqueSpec.perform_all(:normal)
    
    Tag.find("A").outgoings.should =~ ["B"]
    Tag.find("C").incomings.should =~ []
    
    Kratoo.find(@ka.id).all_tag_ids.should =~ ["A","B","C","D","E"]
    Kratoo.find(@kb.id).all_tag_ids.should =~ ["Z","X"]
    Kratoo.find(@kc.id).all_tag_ids.should =~ ["C"]
    Kratoo.find(@kd.id).all_tag_ids.should =~ ["A","B","C","D"]
    Kratoo.find(@ke.id).all_tag_ids.should =~ ["C","E"]
    
  end

end
