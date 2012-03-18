# encoding: utf-8
require 'watir-webdriver'

b = Watir::Browser.start 'bit.ly/watir-webdriver-demo'
#b.select_list(:id => 'entry_1').wait_until_present
b.text_field(:id => 'entry_0').when_present.set 'your name'
b.button(:value => 'ส่ง').click
# b.button(:value => 'ส่ง').wait_while_present
# Watir::Wait.until { b.text.include? 'Thank you' }

b.text.include? 'Thank you'