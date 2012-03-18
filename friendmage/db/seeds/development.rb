
(1..4).each do |i|
  Bank.create({
:id=>i,
:bank_name=>"ไทยพาณิชย์" + i.to_s,
:bank_branch=>"บางกะปิ",
:account_number=>"0123456789",
:account_name=>"whowish",
:account_type=>"ออมทรัพย์"
})
end