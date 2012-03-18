
(1..20).each do |i|
  Figure.create({
:id=>i,
:title_us=>"test" + i.to_s,
:description=>"test" + i.to_s,
:status=>Figure::STATUS_ACTIVE,
:created_date=>Time.now,
:default_pic=>"",
:loves=>3,
:hates=>1,
:dont_cares=>0,
:views=>0,
:creator_facebook_id=>100002085428291,
:country_code=>"US"
})
end

(21..22).each do |i|
  Figure.create({
:id=>i,
:title_us=>"test" + i.to_s,
:description=>"test" + i.to_s,
:status=>Figure::STATUS_PENDING,
:created_date=>Time.now,
:default_pic=>"",
:loves=>3,
:hates=>1,
:dont_cares=>0,
:views=>0,
:creator_facebook_id=>100002085428291,
:country_code=>"US"
})
end

FigureLove.create({
:figure_id=>1,
:facebook_id=>632818246,
:love_type=>"HATE",
:created_date=>Time.now,
:is_anonymous=>0
})

FigureLove.create({
:figure_id=>1,
:facebook_id=>100000201256691,
:love_type=>"LOVE",
:created_date=>Time.now,
:is_anonymous=>0
})
FigureLove.create({
:figure_id=>1,
:facebook_id=>632591624,
:love_type=>"LOVE",
:created_date=>Time.now,
:is_anonymous=>0
})
FigureLove.create({
:figure_id=>1,
:facebook_id=>100002085428291,
:love_type=>"LOVE",
:created_date=>Time.now,
:is_anonymous=>0
})
Language.create({
:name=>"thai",
:code=>"TH"
})
Language.create({
:name=>"japan",
:code=>"JP"
})
Language.create({
:name=>"us",
:code=>"US"
})
Language.create({
:name=>"Korea",
:code=>"KR"
})
Language.create({
:name=>"China",
:code=>"CN"
})

FacebookCache.create( {:name=>"Tanin Na Nakorn",:gender=>"male",:updated_date=>(Time.now-10000000),:facebook_id=>"632818246",:college=>""}) rescue "Duplicate entry"
FacebookCache.create( {:name=>"Nilobol Ariyamongkollert",:gender=>"female",:updated_date=>(Time.now-10000000),:facebook_id=>"100000201256691",:college=>""}) rescue "Duplicate entry"
FacebookCache.create( {:name=>"Tanun Niyomjit",:gender=>"male",:updated_date=>(Time.now-10000000),:facebook_id=>"632591624",:college=>""}) rescue "Duplicate entry"
Member.create( {:name=>"Tanun Niyomjit",:gender=>"male",:facebook_id=>"632591624",:anonymous_name=>"pond",:anonymous_profile_pic=>""}) rescue "Duplicate entry"
Member.create( {:name=>"Tanin Na Nakorn",:gender=>"male",:facebook_id=>"632818246",:anonymous_name=>"Tanin",:anonymous_profile_pic=>""}) rescue "Duplicate entry"
Member.create( {:name=>"Nilobol Ariyamongkollert",:gender=>"female",:facebook_id=>"100000201256691",:anonymous_name=>"ni",:anonymous_profile_pic=>"",:country_code=>"TH",:is_aesir=>true}) rescue "Duplicate entry"