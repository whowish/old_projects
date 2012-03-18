# encoding: utf-8
require 'spec_helper'

describe AdminRoomController do
  
  before(:each) do
    @tag = Tag.create(:name=>"Chalermthai")
    commit_database
  end
  
  
  it "should add a room" do
    xhr :post, :create, {:tag_name=>@tag.name}
    
    body = expect_json_response    
    body['ok'].should be_true
    body['tag_name'].should == @tag.name
    
    commit_database
    
    check_room = Room.first
    check_room.tag.should == @tag.name
    body['room_id'].should == check_room.id
  end
  
  
  it "shouldn't add unknown tag" do
    xhr :post, :create, {:tag_name=>"#{@tag.name}AA"}
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_message'].should == "'#{@tag.name}AA' is not found."
    
    commit_database
    
    check_room = Room.first
    check_room.should be_nil
  end
  
  
  it "shouldn't add redundant room" do
    room = Room.create(:tag=>@tag.name,:ordered_number=>0,:description=>"")
    commit_database

    post :create, {:tag_name=>"#{@tag.name}"}
    
    body = expect_json_response
    body['ok'].should be_false
    body['error_message'].should == "'#{@tag.name}' is already a room."
    
    commit_database
    
    rooms = Room.all
    rooms.length.should == 1
    rooms[0].id.should == room.id
  end
  
  
  it "should delete a room" do
    room = Room.create(:tag=>@tag.name,:ordered_number=>0,:description=>"")
    commit_database
    
    post :remove, {:room_id=>room.id}
    body = expect_json_response
    body['ok'].should be_true
    commit_database
    
    check_room = Room.first(:conditions=>{:_id=>room.id})
    check_room.should be_nil
  end
  
end
