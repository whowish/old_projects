class ProfileController < ApplicationController
  include TemporaryFileHelper
  
  layout "profile"

  def edit_info
    
    @current_member.gender = params[:gender]
    @current_member.about = params[:about]
    @current_member.quote = params[:quote]
    @current_member.save
    
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/profile/info", :locals=>{:user=>@current_member})}
  
  end

  
  def show_edit
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/profile/edit_info", :locals=>{:user=>@current_member})}
  end
  
  
  def cancel_edit
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/profile/info", :locals=>{:user=>@current_member})}
  end
  
  
  def change_picture
    
    if !$member.is_member
      render :json=>{:ok=>false, :error_message=>{:summary=>WhowishWord.word_for(:profile_picture, :not_member)}}
      return
    end
     
    begin
      
      @allow_extensions = ["jpg","jpeg","gif","png"]
      @options = {:max_width => 200}
      
      if params[:Filedata].class == String
        
        data_bytes = request.body.read
        filename = upload_temporary_image(data_bytes,
                                          params[:Filedata],
                                          data_bytes.length,
                                          @allow_extensions,
                                          @options)
      
      else
        
        filename = upload_temporary_image(params[:Filedata].read,
                                          params[:Filedata].original_filename,
                                          params[:Filedata].size,
                                          @allow_extensions,
                                          @options)
      
      end
        
      ext = File.extname( filename ).sub( /^\./, "" ).downcase
      new_path = "/uploads/images/member_#{$member.id}_#{rand(100)}.#{ext}"
      
      
      FileUtils.copy(File.join(Rails.root, "public", CGI.unescape(filename)), 
                      File.join(Rails.root, "public", CGI.unescape(new_path)))
      
      previous_path = $member.profile_picture_path
      previous_thumbnail_path = $member.get_thumbnail_profile_picture_path
      
      $member.profile_picture_path = new_path
      $member.save
        
      FileUtils.remove(File.join(Rails.root, "public", CGI.unescape(filename)), :force=>true)
      
      if previous_path.strip != ""
        FileUtils.remove(File.join(Rails.root, "public", CGI.unescape(previous_path)), :force=>true)
        FileUtils.remove(File.join(Rails.root, "public", CGI.unescape(previous_thumbnail_path)), :force=>true)
      end
      
      image_resize(File.join(Rails.root, "public", $member.profile_picture_path), 
                    50, 
                    50, 
                    File.join(Rails.root, "public", $member.get_thumbnail_profile_picture_path),
                    false)
      
      render :json=>{:ok=>true, :filename=>$member.profile_picture_path}
      
    rescue Exception=>e
      
      render :json=>{:ok=>false, :error_messages=>{:summary=>e.message}}
      
    end
  end
  
  
  before_filter :check_member
  
  private
  def check_member
    
    params[:member_id] ||= $member.id
    @current_member = Member.first(:conditions=>{:_id=>params[:member_id]})
    
    puts params[:member_id]
    puts $member.id
    puts @current_member.inspect
    
    if !@current_member
      if request.xhr?
        render :json=>{:ok=>false, :error_messages=>{:summary=>word_for(:profile, :user_not_found)}}
      else
        render :user_not_found, :layout=>"application"
      end
    end
    
  end
  
end
