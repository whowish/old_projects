
(1..4).each do |i|
  Event.create({
:id=>i,
:title=>"Let's go to the sea" + i.to_s,
:location=>"Hua Hin",
:location_url=>"Hua Hin web",
:description=>"Hua Hin description",
:facebook_id=>"100002085428291",
:status=>Event::STATUS_ACTIVE,
:created_date=>Time.now,
:settled_date=>Time.now,
:default_image_path=>"event_2_2.png",
:category_id=>1
})

EventFriend.create({
:event_id=>i,
:facebook_id=>"632818246",
:status=>EventFriend::STATUS_PENDING
})

EventFriend.create({
:event_id=>i,
:facebook_id=>"632591624",
:status=>EventFriend::STATUS_ACCEPTED
})

EventAvailableDate.create({
:event_id=>i,
:facebook_id=>"100002085428291",
:available_date=>Time.now
})

EventAvailableDate.create({
:event_id=>i,
:facebook_id=>"632591624",
:available_date=>Time.now
})

end

 Event.create({
:id=>5,
:title=>"AAA" ,
:location=>"Hua Hin",
:location_url=>"Hua Hin web",
:description=>"Hua Hin description",
:facebook_id=>"632818246",
:status=>Event::STATUS_ACTIVE,
:created_date=>Time.now,
:settled_date=>Time.now,
:default_image_path=>"event_2_2.png",
:category_id=>1
})

EventFriend.create({
:event_id=>5,
:facebook_id=>"100002085428291",
:status=>EventFriend::STATUS_PENDING
})

EventFriend.create({
:event_id=>5,
:facebook_id=>"632591624",
:status=>EventFriend::STATUS_ACCEPTED
})

EventAvailableDate.create({
:event_id=>5,
:facebook_id=>"632818246",
:available_date=>Time.now
})

EventAvailableDate.create({
:event_id=>5,
:facebook_id=>"632591624",
:available_date=>Time.now
})

Event.create({
:id=>6,
:title=>"event complete friend" ,
:location=>"Hua Hin",
:location_url=>"Hua Hin web",
:description=>"Hua Hin description",
:facebook_id=>"632818246",
:status=>Event::STATUS_COMPLETED,
:created_date=>Time.now,
:settled_date=>Time.now,
:default_image_path=>"event_2_2.png",
:category_id=>1
})

EventFriend.create({
:event_id=>6,
:facebook_id=>"100002085428291",
:status=>EventFriend::STATUS_ACCEPTED
})

EventFriend.create({
:event_id=>6,
:facebook_id=>"632591624",
:status=>EventFriend::STATUS_ACCEPTED
})

EventAvailableDate.create({
:event_id=>6,
:facebook_id=>"632818246",
:available_date=>Time.now
})

EventAvailableDate.create({
:event_id=>6,
:facebook_id=>"632591624",
:available_date=>Time.now
})

Event.create({
:id=>7,
:title=>"event complete my" ,
:location=>"Hua Hin",
:location_url=>"Hua Hin web",
:description=>"Hua Hin description",
:facebook_id=>"100002085428291",
:status=>Event::STATUS_COMPLETED,
:created_date=>Time.now,
:settled_date=>Time.now,
:default_image_path=>"event_2_2.png",
:category_id=>1
})

EventFriend.create({
:event_id=>7,
:facebook_id=>"632818246",
:status=>EventFriend::STATUS_ACCEPTED
})

EventFriend.create({
:event_id=>7,
:facebook_id=>"632591624",
:status=>EventFriend::STATUS_ACCEPTED
})

EventAvailableDate.create({
:event_id=>7,
:facebook_id=>"632818246",
:available_date=>Time.now
})

EventAvailableDate.create({
:event_id=>7,
:facebook_id=>"632591624",
:available_date=>Time.now
})

Event.create({
:id=>8,
:title=>"event settled" ,
:location=>"Hua Hin",
:location_url=>"Hua Hin web",
:description=>"Hua Hin description",
:facebook_id=>"100002085428291",
:status=>Event::STATUS_SETTLED,
:created_date=>Time.now,
:settled_date=>Time.now,
:default_image_path=>"event_2_2.png",
:category_id=>1
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-01 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-02 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-03 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-04 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-05 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-06 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-07 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-08 07:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-09 07:00:00"
})
EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-10 07:00:00"
})
EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-11 07:00:00"
})
EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-01 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-02 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-03 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-04 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-05 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-06 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-07 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-08 08:00:00"
})

EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-09 08:00:00"
})
EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-10 08:00:00"
})
EventSettledDate.create({
:event_id=>8,
:settled_date=>"2011-03-11 08:00:00"
})

FacebookCache.create( {:name=>"Tanin Na Nakorn",:gender=>"male",:updated_date=>(Time.now-10000000),:facebook_id=>"632818246",:college=>""})
FacebookCache.create( {:name=>"Nilobol Ariyamongkollert",:gender=>"female",:updated_date=>(Time.now-10000000),:facebook_id=>"100000201256691",:college=>""})
FacebookCache.create( {:name=>"Tanun Niyomjit",:gender=>"male",:updated_date=>(Time.now-10000000),:facebook_id=>"632591624",:college=>""})
