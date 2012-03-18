require 'spec_helper'

describe Kratoo do
  
  # Mock
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
  #
  
  before(:each) do
    Tag.create(:_id=>"A",:name=>"A",:outgoings=>["B","C"],:incomings=>[])
    Tag.create(:_id=>"B",:name=>"B",:outgoings=>["D"],:incomings=>["A"])
    Tag.create(:_id=>"C",:name=>"C",:outgoings=>["D","E"],:incomings=>["A"])
    Tag.create(:_id=>"D",:name=>"D",:outgoings=>[],:incomings=>["B","C"])
    Tag.create(:_id=>"E",:name=>"E",:outgoings=>[],:incomings=>["C"])
    
    Tag.create(:_id=>"F",:name=>"F",:alias_with_tag=>"E")
    Tag.create(:_id=>"G",:name=>"G",:alias_with_tag=>"C")
    
    Tag.create(:_id=>"Z",:name=>"Z",:outgoings=>["X"],:incomings=>[])
    Tag.create(:_id=>"X",:name=>"X",:outgoings=>[],:incomings=>["Z"])
  end
  
  it "does not reduce because there is no related tags" do
    kratoo = Kratoo.new(:tag_ids=>["B","E","Z"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["B","E","Z"]
    kratoo.all_tag_ids.should =~ ["A","B","C","E","Z"]
  end
  
  it "must reduce direct parent" do
    kratoo = Kratoo.new(:tag_ids=>["A","B","C"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["B","C"]
    kratoo.all_tag_ids.should =~ ["A","B","C"]
  end
  
  it "must reduce indirect parent" do
    kratoo = Kratoo.new(:tag_ids=>["A","C","D","E"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["D","E"]
    kratoo.all_tag_ids.should =~ ["A","B","C","D","E"]
  end
  
  it "reduce child's alias" do
    kratoo = Kratoo.new(:tag_ids=>["B","C","F"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["B","F"]
    kratoo.all_tag_ids.should =~ ["A","B","C","E"]
  end
  
  it "reduce multiple child's alias" do
    kratoo = Kratoo.new(:tag_ids=>["B","G","F"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["B","F"]
    kratoo.all_tag_ids.should =~ ["A","B","C","E"]
  end
  
  it "reduce parent's alias" do
    kratoo = Kratoo.new(:tag_ids=>["B","G","E"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["B","E"]
    kratoo.all_tag_ids.should =~ ["A","B","C","E"]
  end

  it "reduce many parents" do
    kratoo = Kratoo.new(:tag_ids=>["A","B","C","D"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["D"]
    kratoo.all_tag_ids.should =~ ["A","B","C","D"]
  end
  
  it "reduce multiple parents and some with alias" do
    kratoo = Kratoo.new(:tag_ids=>["A","B","G","D"])
    kratoo.organize_tags
    
    kratoo.tag_ids.should =~ ["D"]
    kratoo.all_tag_ids.should =~ ["A","B","C","D"]
  end
  
  
end