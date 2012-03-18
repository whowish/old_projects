# encoding: utf-8
require 'spec_helper'

describe 'AdminRoomController' do
  
  before(:each) do
    @tag = Tag.create(:name=>"Chalermthai")
  end
  
  it "adds new room" do
    goto '/admin_room'
    
    fill "tag_name", @tag.name
    click "tag_submit_button"
    
    wait_until { value("tag_name") == "" }
    commit_database
    
    room = Room.first
    html("room_#{room.id}").should include(@tag.name)
  end
  
  it "shouldn't add a room if the tag does not exist" do

    goto '/admin_room'
    
    fill "tag_name", "#{@tag.name}AAA"
    click "tag_submit_button"
    
    expect_alert("'#{@tag.name}AAA' is not found.")
  end
  
  it "shouldn't add redundant room" do

    Room.create(:tag=>@tag.name)
    commit_database

    goto '/admin_room'
    
    fill "tag_name", @tag.name
    click "tag_submit_button"

    expect_alert("'#{@tag.name}' is already a room.")
  end
  
  it "removes a room" do
    
    room = Room.create(:tag=>@tag.name)
    commit_database

    goto '/admin_room'
    
    exists?(:id=>"room_#{room.id}").should be_true
    click_object(element(:class=>"trash-icon"))

    wait_until { !exists?(:id=>"room_#{room.id}") }
    
  end

end