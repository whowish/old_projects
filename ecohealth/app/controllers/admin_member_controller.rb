class AdminMemberController < AdminController
  def delete
     member = Member.first(:conditions=>{:id=>params[:member_id]})
     member.status = Member::STATUS_DELETED
     member.save
     render :json=>{:ok=>true}
  end
  def edit
     member = Member.first(:conditions=>{:id=>params[:member_id]})
     member.member_type = params[:member_type]
     member.save
     render :json=>{:ok=>true}
  end
end
