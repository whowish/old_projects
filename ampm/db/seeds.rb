# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"title",:content=>"Title:",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"title_default_text",:content=>"Your event title here",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"location",:content=>"Location:",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"location_default_text",:content=>"Your location here",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"location_url",:content=>"Location URL:",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"location_url_default_text",:content=>"Your location URL here",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"description",:content=>"Description:",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"description_default_text",:content=>"Your description here",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"title_tab",:content=>"Please specify event title",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"select_date_tab",:content=>"Please select available date",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"invite_friend_tab",:content=>"Please invite friend",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"description_tab",:content=>"Please fill description (Optional)",:locale=>"en"})


WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"notify_friend",:content=>"Notify friends on their walls",:locale=>"en"})

WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"title_instruction",:content=>"Specify title",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"available_day_instruction",:content=>"Select available date",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"available_time_instruction",:content=>"Select available time",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"invite_friend_instruction",:content=>"Invite friends",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"map_and_detail_instruction",:content=>"Specify map and details (optional)",:locale=>"en"})


WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"add_button",:content=>"Create Event",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"edit_button",:content=>"Save Event",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"create_event_page_name",:content=>"Create New Event",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-add", :page_id =>"event/index.html.erb",:word_id=>"edit_event_page_name",:content=>"Edit Event",:locale=>"en"})


WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"accept_button",:content=>"Join!",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"reject_button",:content=>"Unavailable",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"edit_response_button",:content=>"Edit",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"edit_event_button",:content=>"Edit",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"event_delete_button",:content=>"Cancel this event",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"event_settled_button",:content=>"Settled Date",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-response", :page_id =>"event/view.html.erb",:word_id=>"cancel_settled_event_button",:content=>"Cancel Settled Date",:locale=>"en"})

WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"time",:content=>"Time",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"timeline_tab",:content=>"Please, Set up your available date and time &nabla;",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"map_and_description_tab",:content=>"Map and other detail",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"friend_accept",:content=>"{number} accepted",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"friend_reject",:content=>"{number} rejected",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"friend_list_label",:content=>"Friends",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"invite",:content=>"Invite more friend?",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"approve_friend",:content=>"More friends was invited",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"comment_tab",:content=>"Comment",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"title_delete",:content=>"Delete",:locale=>"en"})

WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"instruction_creator",:content=>"{number} people have responded. \
If you want to confirm the meeting now, please highlight the date/time that works best for everyone, and click the confirm button below.",:locale=>"en"})

WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"instruction_invitee_confirmed",:content=>"You have responded. \
Would you like to change your response?",:locale=>"en"})

WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"instruction_invitee_pending",:content=>"You are invited! \
Please select the date and/or time that works best for you. You can select more than one or click \“unavailable\” to decline the invitation. It is recommended \
that you select times which others have already said are good. After this, the coordinator will confirm the date(s) that works best for everyone.",:locale=>"en"})

WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"instruction_viewer",:content=>"You are not on the list.",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"invite_yourself",:content=>"Request an invitation",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"invite_yourself",:content=>"ขอเสือกกับการนัดครั้งนี้",:locale=>"th"})

WhowishWord.create({ :page_name=>"confirm_delete", :page_id =>"event/confirm_delete.html.erb",:word_id=>"delete",:content=>"Delete",:locale=>"en"})
WhowishWord.create({ :page_name=>"confirm_delete", :page_id =>"event/confirm_delete.html.erb",:word_id=>"cancel",:content=>"Cancel",:locale=>"en"})

WhowishWord.create({ :page_name=>"header", :page_id =>"profile/index.html.erb",:word_id=>"home",:content=>"Home",:locale=>"en"})
WhowishWord.create({ :page_name=>"header", :page_id =>"profile/index.html.erb",:word_id=>"create_new_meeting",:content=>"Create New Meeting",:locale=>"en"})
WhowishWord.create({ :page_name=>"header", :page_id =>"profile/index.html.erb",:word_id=>"profile",:content=>"My Events",:locale=>"en"})

WhowishWord.create({ :page_name=>"header", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"unsettled",:content=>"Unsettled",:locale=>"en"})

WhowishWord.create({ :page_name=>"usermailer", :page_id =>"user_mailer/notify_create_event.html.erb",:word_id=>"subject",:content=>"You've got an invitation!",:locale=>"en"})
WhowishWord.create({ :page_name=>"usermailer", :page_id =>"user_mailer/notify_create_event.html.erb",:word_id=>"title",:content=>"You've got an invitation from {event_creator}",:locale=>"en"})

WhowishWord.create({ :page_name=>"home_create", :page_id =>"home/index.html.erb",:word_id=>"create_line1",:content=>"What are you waiting for?",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_create", :page_id =>"home/index.html.erb",:word_id=>"create_line2",:content=>"START",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_create", :page_id =>"home/index.html.erb",:word_id=>"create_line3",:content=>"Create New Event",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_create", :page_id =>"home/index.html.erb",:word_id=>"create_line4",:content=>"NOW!!!",:locale=>"en"})

WhowishWord.create({ :page_name=>"home_settled", :page_id =>"home/index.html.erb",:word_id=>"settled_line1",:content=>"You've",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_settled", :page_id =>"home/index.html.erb",:word_id=>"settled_line3",:content=>"event to finish",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_settled", :page_id =>"home/_event_unsettle.html.erb",:word_id=>"settled_hover_join",:content=>"people join this event",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_settled", :page_id =>"home/_event_unsettle.html.erb",:word_id=>"settled_hover_button",:content=>"Settle!",:locale=>"en"})

WhowishWord.create({ :page_name=>"home_invited", :page_id =>"home/_event_invited.html.erb",:word_id=>"invite",:content=>"invite you in",:locale=>"en"})
WhowishWord.create({ :page_name=>"home_soonest_event", :page_id =>"home/_event_soonest.html.erb",:word_id=>"event_by",:content=>"event by",:locale=>"en"})

WhowishWord.create({ :page_name=>"home", :page_id =>"home/index.html.erb",:word_id=>"view_all",:content=>"View all",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/index.html.erb",:word_id=>"next",:content=>"Next",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/index.html.erb",:word_id=>"prev",:content=>"Prev",:locale=>"en"})

WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_unsettle.html.erb",:word_id=>"view_all",:content=>"View all",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_unsettle.html.erb",:word_id=>"next",:content=>"Next",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_unsettle.html.erb",:word_id=>"prev",:content=>"Prev",:locale=>"en"})

WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_invited.html.erb",:word_id=>"view_all",:content=>"View all",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_invited.html.erb",:word_id=>"next",:content=>"Next",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_invited.html.erb",:word_id=>"prev",:content=>"Prev",:locale=>"en"})

WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_soonest.html.erb",:word_id=>"view_all",:content=>"View all",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_soonest.html.erb",:word_id=>"next",:content=>"Next",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_soonest.html.erb",:word_id=>"prev",:content=>"Prev",:locale=>"en"})

WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_invited.html.erb",:word_id=>"accept_button",:content=>"Accept",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/_event_invited.html.erb",:word_id=>"reject_button",:content=>"Reject",:locale=>"en"})

WhowishWord.create({ :page_name=>"home", :page_id =>"home/index.html.erb",:word_id=>"accept_button",:content=>"Accept",:locale=>"en"})
WhowishWord.create({ :page_name=>"home", :page_id =>"home/index.html.erb",:word_id=>"reject_button",:content=>"Reject",:locale=>"en"})

WhowishWord.create({ :page_name=>"side", :page_id =>"profile/_recent_event.html.erb",:word_id=>"recent_event",:content=>"Recent Events",:locale=>"en"})

WhowishWord.create({ :page_name=>"side", :page_id =>"profile/_side_event_stat.html.erb",:word_id=>"joined_event",:content=>"events to go",:locale=>"en"})
WhowishWord.create({ :page_name=>"side", :page_id =>"profile/_side_event_stat.html.erb",:word_id=>"invited_event",:content=>"events to reply",:locale=>"en"})
WhowishWord.create({ :page_name=>"side", :page_id =>"profile/_side_event_stat.html.erb",:word_id=>"pending_event",:content=>"events to settle",:locale=>"en"})


WhowishWord.create({ :page_name=>"side", :page_id =>"profile/_side_friend.html.erb",:word_id=>"friend_topic",:content=>"Friends in App ({all_friend})",:locale=>"en"})
WhowishWord.create({ :page_name=>"side", :page_id =>"profile/_side_friend.html.erb",:word_id=>"view_all",:content=>"View all",:locale=>"en"})
WhowishWord.create({ :page_name=>"side", :page_id =>"friend/view_all.html.erb",:word_id=>"friend_topic",:content=>"Friends in App ({all_friend})",:locale=>"en"})
WhowishWord.create({ :page_name=>"invite",:page_id =>"invite_friend/index.html.erb",:word_id=>"invite_content",:content=>"Check out 2Meet4! I'm using it now and its pretty cool.",:locale=>"en"})
WhowishWord.create({ :page_name=>"invite",:page_id =>"invite_friend/index.html.erb",:word_id=>"invite_action_text",:content=>"Invite your friends to join 2Meet4",:locale=>"en"})

WhowishWord.create({ :page_name=>"profile", :page_id =>"profile/_filter_bar.html.erb",:word_id=>"filter_unsettled",:content=>"Unconfirmed",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile", :page_id =>"profile/_filter_bar.html.erb",:word_id=>"filter_settled",:content=>"Confirmed",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile", :page_id =>"profile/_filter_bar.html.erb",:word_id=>"ending_soonest",:content=>"Ending Soonest",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile", :page_id =>"profile/_filter_bar.html.erb",:word_id=>"completed",:content=>"Completed",:locale=>"en"})

WhowishWord.create({ :page_name=>"comment_add", :page_id =>"comment/_comment_add.html.erb",:word_id=>"comment_add",:content=>"comment",:locale=>"en"})
WhowishWord.create({ :page_name=>"comment_delete", :page_id =>"comment/confirm_delete.html.erb",:word_id=>"confirm",:content=>"Are you sure you want to delete this comment?",:locale=>"en"})
WhowishWord.create({ :page_name=>"comment_delete", :page_id =>"comment/confirm_delete.html.erb",:word_id=>"delete_button",:content=>"Delete",:locale=>"en"})
WhowishWord.create({ :page_name=>"comment_delete", :page_id =>"comment/confirm_delete.html.erb",:word_id=>"cancel_button",:content=>"Cancel",:locale=>"en"})
WhowishWord.create({ :page_name=>"comment_delete", :page_id =>"comment/confirm_delete.html.erb",:word_id=>"notify_friend",:content=>"Notify friends on their walls",:locale=>"en"})

WhowishWord.create({ :page_name=>"comment_status", :page_id =>"comment/_comment_status.html.erb",:word_id=>"other_love_comment",:content=>"{like_count} people love this",:locale=>"en"})
WhowishWord.create({ :page_name=>"comment_status", :page_id =>"comment/_comment_status.html.erb",:word_id=>"you_love_comment",:content=>"You love this",:locale=>"en"})
WhowishWord.create({ :page_name=>"comment_status", :page_id =>"comment/_comment_status.html.erb",:word_id=>"both_love_comment",:content=>"You and {like_count} people love this",:locale=>"en"})

WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"accept_event",:content=>"you've joined this meeting.",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"edit_button",:content=>"Edit your response",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"join_button",:content=>"Wanna JOIN this meeting?",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"reject_button",:content=>"No, Thanks",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"reject_event",:content=>"you've rejected this meeting.",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"edit_reject_button",:content=>"Change your mind?",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"settle_event",:content=>"you've Created this meeting.",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"settle_button",:content=>"Confirm Meeting?",:locale=>"en"})
WhowishWord.create({ :page_name=>"profile_unsettled", :page_id =>"profile/_day_unsettled.html.erb",:word_id=>"edit_event_button",:content=>"Edit this meeting",:locale=>"en"})

WhowishWord.create({ :page_name=>"invite_friend", :page_id =>"event/invite.html.erb",:word_id=>"invite_friend_tab",:content=>"Please invite friend",:locale=>"en"})
WhowishWord.create({ :page_name=>"invite_friend", :page_id =>"event/invite.html.erb",:word_id=>"notify_friend",:content=>"notify_friend",:locale=>"en"})
WhowishWord.create({ :page_name=>"invite_friend", :page_id =>"event/invite.html.erb",:word_id=>"invite_button",:content=>"invite",:locale=>"en"})
WhowishWord.create({ :page_name=>"invite_friend", :page_id =>"event/invite.html.erb",:word_id=>"invite_yourself",:content=>"Wanna join this meeting",:locale=>"en"})

WhowishWord.create({ :page_name=>"invite_friend", :page_id =>"event/_approve_friend.html.erb",:word_id=>"accept",:content=>"Allow",:locale=>"en"})
WhowishWord.create({ :page_name=>"invite_friend", :page_id =>"event/_approve_friend.html.erb",:word_id=>"reject",:content=>"Don't Allow",:locale=>"en"})

WhowishWord.create({ :page_name=>"comment-add", :page_id =>"comment/_comment_add.html.erb",:word_id=>"notify_friend",:content=>"Notify friends on their walls",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"notify_friend",:content=>"Notify friends on their walls",:locale=>"en"})
WhowishWord.create({ :page_name=>"event-view", :page_id =>"event/view.html.erb",:word_id=>"notify_creator",:content=>"Notify creator on wall",:locale=>"en"})

Category.create({
    :id=>1,
    :name=>"Friends",
    :parent_id=>1,
    :original_image_path=>"",
    :thumbnail_image_path=>"",
    :class_name=>"friend_icon"
})

Category.create({
    :id=>2,
    :name=>"Family",
    :parent_id=>4,
    :original_image_path=>"",
    :thumbnail_image_path=>"",
    :class_name=>"family_icon"
})

Category.create({
    :id=>3,
    :name=>"Business",
    :parent_id=>4,
    :original_image_path=>"",
    :thumbnail_image_path=>"",
    :class_name=>"business_icon"
})

Category.create({
    :id=>4,
    :name=>"Personal",
    :parent_id=>2,
    :original_image_path=>"",
    :thumbnail_image_path=>"",
    :class_name=>"personal_icon"
})

Category.create({
    :id=>5,
    :name=>"Professional",
    :parent_id=>3,
    :original_image_path=>"",
    :thumbnail_image_path=>"",
    :class_name=>"professional_icon"
})

require File.join('db','seeds',Rails.env)
