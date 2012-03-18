# encoding: utf-8

module MemberActionRspecHelper
  
  def mock_member_action(member,entity)
    member_action = MemberAction.new
    member_action.member_id = member.id
    member_action.created_date = Time.now
    member_action.entity = entity
    member_action.save
    
    return member_action
  end
end