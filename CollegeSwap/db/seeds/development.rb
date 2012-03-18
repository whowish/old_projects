
members = []
members.push Member.create(:facebook_id=>"632818246",:college_id=>1,:is_aesir=>1)
members.push Member.create(:facebook_id=>"100000201256691",:college_id=>1,:is_aesir=>1)
members.push Member.create(:facebook_id=>"632591624",:college_id=>1,:is_aesir=>1)

(1..10).each { |i|

  members.each { |member|
    item = Item.create({:title=>"test " +i.to_s,
                :item_type=>"WISH",
                :value=>(1.20+i).to_f,
                :description=>"XXXX",
                :facebook_id=>member.facebook_id,
                :created_date=> DateTime.now,
                :category_id=>1,
                :owner_name=>"test name",
                :owner_university=>"Chulalongkorn University",
                :country_code=>"TH",
                :privacy=>"ALL",
                :default_image_path=>"item_1.jpg"}
                )
                
    ItemImage.create({
                  :item_id=>item.id,
                  :original_image_path=>"item_1.jpg",
                  :ordered_number=>1
                })
  }

}

(1..10).each { |i|

  members.each { |member|
  item = Item.create({:title=>"test " +i.to_s,
              :item_type=>"JUNK",
              :value=>(0.99+i).to_f,
              :description=>"XXXX",
              :facebook_id=>member.facebook_id,
              :created_date=> DateTime.now,
              :category_id=>1,
              :flags=>2,
              :owner_name=>"test name",
              :owner_university=>"Chulalongkorn University",
              :country_code=>"TH",
              :privacy=>"ALL",
              :default_image_path=>"item_2.jpg"}
              )
             
  Flag.create({
                :item_id=>item.id,
                :facebook_id=>member.facebook_id,
                :created_date=> DateTime.now,
                :reason=>"reason test 1"
              })
  Flag.create({
                :item_id=>item.id,
                :facebook_id=>member.facebook_id,
                :created_date=> DateTime.now,
                :reason=>"reason test 2"
              })

  ItemImage.create({
                :item_id=>item.id,
                :original_image_path=>"item_2.jpg",
                :ordered_number=>1
              })
  }
}


Request.create({
    :id=> 1,
    :requestor_item_id=> 21,
    :responder_item_id=>22,
    :message=>"message test",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "PENDING",
    :requestor_facebook_id=> "100000201256691",
    :responder_facebook_id=> "632818246",
    :is_read=>0
})

Request.create({
    :id=> 2,
    :requestor_item_id=> 23,
    :responder_item_id=>24,
    :message=>"message test",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "ACCEPTED",
    :requestor_facebook_id=> "100000201256691",
    :responder_facebook_id=> "632818246",
    :is_read=>0
})
Request.create({
    :id=> 3,
    :requestor_item_id=> 25,
    :responder_item_id=>26,
    :message=>"message test",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "REJECTED",
    :requestor_facebook_id=> "100000201256691",
    :responder_facebook_id=> "632818246",
    :is_read=>1
})

Request.create({
    :id=> 4,
    :requestor_item_id=> 28,
    :responder_item_id=>27,
    :message=>"message test2",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "PENDING",
    :requestor_facebook_id=> "632818246" ,
    :responder_facebook_id=> "100000201256691",
    :is_read=>0
})

Request.create({
    :id=> 4,
    :requestor_item_id=> 28,
    :responder_item_id=>27,
    :message=>"message test2",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "PENDING",
    :requestor_facebook_id=> "632818246" ,
    :responder_facebook_id=> "100000201256691",
    :is_read=>0
})

Request.create({
    :id=> 4,
    :requestor_item_id=> 28,
    :responder_item_id=>27,
    :message=>"message test2",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "PENDING",
    :requestor_facebook_id=> "632818246" ,
    :responder_facebook_id=> "100000201256691",
    :is_read=>0
})

Request.create({
    :id=> 4,
    :requestor_item_id=> 28,
    :responder_item_id=>27,
    :message=>"message test2",
    :response_message=> "",
    :created_date=> DateTime.now,
    :response_time=> DateTime.now,
    :status=> "PENDING",
    :requestor_facebook_id=> "632818246" ,
    :responder_facebook_id=> "100000201256691",
    :is_read=>0
})

Request.create({
    :id=> 4,
    :requestor_item_id=> 28,
    :responder_item_id=>27,
    :message=>"love it!!!",
    :response_message=> "",
    :created_date=> DateTime.now,
    :status=> "ACCEPTED",
    :requestor_facebook_id=> "632818246" ,
    :responder_facebook_id=> "100000201256691",
    :response_message=> "let's meet",
    :response_time => DateTime.now
})

