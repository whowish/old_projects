require 'test_helper'

class AdminFigureControllerTest < ActionController::TestCase
  # Replace this with your real tests.
   test "test merge" do
      
    post :merge,{:main_figure_id=> 1,
               :merge_figure_list=>"2"
    }  
  
    main_figure = Figure.first(:conditions=>{:id=>1})
    assert_equal main_figure.title_us,figures(:figure1).title_us
    assert_equal main_figure.description,figures(:figure1).description
    assert_equal main_figure.default_pic,figures(:figure1).default_pic
    assert_equal main_figure.created_date,figures(:figure1).created_date
    assert_equal main_figure.status,figures(:figure1).status
    assert_equal main_figure.loves,0
    assert_equal main_figure.hates,3
    assert_equal main_figure.dont_cares,1
    assert_equal main_figure.views,9
    assert_equal main_figure.creator_facebook_id,figures(:figure1).creator_facebook_id
    assert_equal main_figure.country_code,figures(:figure1).country_code
    assert_equal main_figure.title_th,figures(:figure1).title_th
    assert_equal main_figure.title_jp,figures(:figure1).title_jp
    assert_equal main_figure.title_kr,figures(:figure1).title_kr
    assert_equal main_figure.title_cn,figures(:figure1).title_cn
    assert_equal main_figure.tags,figures(:figure1).tags
    assert_equal main_figure.value,figures(:figure1).value
    assert_equal main_figure.manager_facebook_id,figures(:figure1).manager_facebook_id
    assert_equal main_figure.bid_start_time,figures(:figure1).bid_start_time
    assert_equal main_figure.bid_status,figures(:figure1).bid_status
    assert_equal main_figure.zip_file_path,figures(:figure1).zip_file_path
    
    love = FigureLove.all(:conditions=>{:figure_id=>1},:order=>"id asc")
    #assert_equal love.length,4
    assert_equal love[0].facebook_id,632591624
    assert_equal love[0].love_type,FigureLove::TYPE_HATE
    assert_equal love[2].facebook_id,632818246
    assert_equal love[2].love_type,FigureLove::TYPE_HATE
    assert_equal love[1].facebook_id,100000201256691
    assert_equal love[1].love_type,FigureLove::TYPE_DONT_CARE
    assert_equal love[3].facebook_id,100002085428291
    assert_equal love[3].love_type,FigureLove::TYPE_HATE
    
    m1 = Member.first(:conditions=>{:facebook_id=>632591624})
    m2 = Member.first(:conditions=>{:facebook_id=>632818246})
    m3 = Member.first(:conditions=>{:facebook_id=>100000201256691})
    m4 = Member.first(:conditions=>{:facebook_id=>100002085428291})
    
    assert_equal m1.credits,10
    assert_equal m2.credits,10
    assert_equal m3.credits,10
    assert_equal m4.credits,160
    
    merge_figure_loves = FigureLove.all(:conditions=>{:figure_id=>2},:order=>"id asc")
    assert_equal merge_figure_loves.length,0
    
    bid_request = BidRequest.all(:conditions=>{:figure_id=>1},:order=>"id asc")
    assert_equal bid_request.length,1
    assert_equal bid_request[0].facebook_id,bid_requests(:request1_1).facebook_id
    assert_equal bid_request[0].value,bid_requests(:request1_1).value
    assert_equal bid_request[0].figure_id,bid_requests(:request1_1).figure_id
    
    merge_bid_requests = BidRequest.all(:conditions=>{:figure_id=>2},:order=>"id asc")
    assert_equal merge_bid_requests.length,1
    assert_equal merge_bid_requests[0].status,BidRequest::STATUS_FAILED_SETTLED
    
    cm = Comment.all(:conditions=>{:figure_id=>1},:order=>"id asc")
    assert_equal cm.length,2
    
    old_cm = Comment.all(:conditions=>{:figure_id=>2},:order=>"id asc")
    assert_equal old_cm.length,0
    
    img = FigureImage.all(:conditions=>{:figure_id=>1},:order=>"id asc")
    assert_equal img.length,4
    
    old_img = FigureImage.all(:conditions=>{:figure_id=>2},:order=>"id asc")
    assert_equal old_img.length,0
    
    tag = FigureTag.all(:conditions=>{:figure_id=>1},:order=>"id asc")
    assert_equal tag.length,1
    
    old_tag = FigureTag.all(:conditions=>{:figure_id=>2},:order=>"id asc")
    assert_equal old_tag.length,0
    
    
  end
end




  