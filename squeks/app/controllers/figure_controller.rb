class FigureController < ApplicationController
  include FigureHelper
  
  def add

    if $facebook.is_guest
      render :json=>{:ok=>false, :error_message=>MUST_LOGIN_ERROR}
      return
    end

    languages = Language.all()

    @figure = Figure.new()
    languages.each do |language|
      @figure["title_"+language.code.downcase] = params[("title_"+language.code.downcase).to_sym]
      
      forbidden_words = WordFilter.get_forbidden_words(@figure["title_"+language.code.downcase])
      
      if forbidden_words.length > 0
        render :json => {:ok=>false,:error_message=>"Please avoid these words: #{forbidden_words.join(" ,")}"}
        return
      end
    end

    @figure.title_us = @figure.title_us.split(' ').map{|t| t.capitalize}.join(' ')
    
    if @figure.title == "" or @figure.title == nil
      render :json=>{:ok=>false, :error_message=>"Title cannot be blank"}
      return
    end

    @figure.description = params[:description]
    @figure.status = Figure::STATUS_PENDING
    @figure.creator_facebook_id = $member.facebook_id
    if params[:is_manager] == "yes"
      @figure.manager_facebook_id = $member.facebook_id
    else
      @figure.manager_facebook_id = 0
    end
    @figure.value =3
    @figure.bid_status = Figure::BID_STATUS_SETTLED
    @figure.country_code = $member.country_code
    @figure.created_date = Time.now
    @figure.loves = 0
    @figure.hates = 0
    @figure.dont_cares = 0
    @figure.views = 0

    if !@figure.save
      render :json=>{:ok=>false, :error_message=>format_error(@figure.errors)}
      return
    end
    
    @figure.update_figure_tag(params[:tags])
    @figure.tags = @figure.get_tags_column
    @figure.update_picture(params[:images])
    @figure.default_pic = ""
    default_image = FigureImage.first(:conditions=>{:figure_id => @figure.id})
    @figure.default_pic = default_image.original_image_path if default_image
    @figure.save
    
    #Feed.create_feed(@figure) => feed after admin approve
    
    $facebook.add_credit(POINT_ADD_FIGURE)

    render :json=>{:ok=>true,:figure_url=>@figure.get_url,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:html=>(render_to_string :partial=>"figure/view_page",:locals=>{:figure=>@figure})}
  end

  def add_image

    #absolutely necessary, otherwise the browser will force download
    response.headers['Content-type'] = 'text/plain; charset=utf-8'
    
    image_data = params[:Filedata]

    if image_data.size > 8000000
        render :text=>"<html><body>"+ActiveSupport::JSON.encode({:ok=>false,:error_message=>"The image cannot exceed 4MB"})+"</body></html>"
        return
    end

    logger.debug { "image=#{image_data}"}

    logger.info {"FigureController.add_image()"}
    logger.info { "figure_id=#{params[:figure_id]},filename=#{image_data.original_filename}"}

    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    
    if !@figure.active?
        render :text=>"<html><body>"+ActiveSupport::JSON.encode({:ok=>false,:error_message=>"This figure is not valid because it is deleted by admin."})+"</body></html>"
        return
    end

    img = FigureImage.create(:figure_id=>@figure.id,
                          :ordered_number=>1000000,
                          :original_image_path=>"")

    ext = File.extname( image_data.original_filename ).sub( /^\./, "" ).downcase

    logger.debug{ "ext=#{ext}"}

    if !["jpg","jpeg","gif","png"].include?(ext)

      render :text=>"<html><body>"+ActiveSupport::JSON.encode({:ok=>false,:error_message=>"The extension (#{ext}) is not allowed."})+"</body></html>"
      return
    end

    img.original_image_path = "figure_#{@figure.id}_#{img.id}.#{ext}"
    img.save
    
    Feed.create_feed(img)

    logger.debug {"new_filename=#{img.original_image_path}"}

    begin
      image_url = ""
      if ENV['S3_ENABLED']

        AWS::S3::S3Object.store(get_server_path_of(img.original_image_path), image_data.read, AWS_S3_BUCKET_NAME,:access=>:public_read)
        image_url = "http://s3.amazonaws.com/"+AWS_S3_BUCKET_NAME+"/uploads/"+img.original_image_path

      else

        File.open(get_server_path_of(img.original_image_path), "wb") { |f|
          f.write(image_data.read)
        }

        File.chmod(0777, get_server_path_of(img.original_image_path))
        image_url = "/uploads/#{img.original_image_path}"
      end

      begin
        ["660x330","50x50","160x160"].each { |size|
          tokens = size.split('x')
          make_thumbnail(img.original_image_path, tokens[0].to_i, tokens[1].to_i)
        }
      rescue
      end

      Delayed::Job.enqueue ImageResizer.new(img.original_image_path)
      Delayed::Job.enqueue CreateZipImageHelper.new(img.figure_id)

      logger.debug {"Success image_url=#{image_url}"}
#      $facebook.add_credit(POINT_ADD_IMAGE)
      render :text=>"<html><body>"+ActiveSupport::JSON.encode({:ok=>true,
                      :image_url=>image_url,
                      :credits=>$facebook.credits,
                      :previous_credits=>$facebook[:previous_credits],
                      :image_id=>img.id,
                      :thumbnail_url=>img.get_160x160_thumbnail_image_url,
                      :thumbnail_html=>URI.escape(render_to_string :partial=>"figure/image_thumbnail",:locals=>{:image=>img})
                      })+"</body></html>"

      @figure.set_default_image
    rescue Exception=>e

      delete_image(img.original_image_path) rescue ""

      logger.debug {"Fail #{e.to_s_with_trace}"}
      render :text=>"<html><body>"+ActiveSupport::JSON.encode({:ok=>false, :error_message=>"The uploading has failed. Please try again. #{e}"})+"</body></html>"
    end
  end
  
  def delete_picture
    
    img = FigureImage.first(:conditions=>{:id=>params[:figure_image_id]})
    
    @figure = Figure.first(:conditions=>{:id =>img.figure_id})
    
    if !@figure.active?
      render :text=>"<html><body>"+ActiveSupport::JSON.encode({:ok=>false,:error_message=>"This figure is not valid because it is deleted by admin."})+"</body></html>"
      return
    end
    
    image_path = img.original_image_path
    figure_id = img.figure_id
    
    Delayed::Job.enqueue CreateZipImageHelper.new(img.figure_id)
    
    #delete record
    img.destroy    

    #delete file
    delete_image(image_path) rescue ""
    
    figure = Figure.first(:conditions=>{:id=>figure_id})
    figure.set_default_image
    
    render :json=>{:ok=>true}
    
  end
  
  def download_pictures
    
    if $facebook.is_guest
      render :json=>{:ok=>false, :error_message=>MUST_LOGIN_ERROR}
      return
    end
    
    figure = Figure.first(:conditions=>{:id=>params[:figure_id]})

    if !figure.active?
      render :json=>{:ok=>false,:error_message=>"This figure is not valid anymore because it is deleted by admin."}
      return
    end
    
    if $facebook.facebook_id != figure.manager_facebook_id
      $facebook.add_credit(-3)
      
      Member.add_credit_to_facebook_id(figure.manager_facebook_id,3) if figure.manager_facebook_id > 0
    end
    
    
    
    render :json=>{:ok=>true, :credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:redirect_url=>"http://s3.amazonaws.com/#{AWS_S3_BUCKET_NAME}/uploads/#{figure.zip_file_path}"}
  end
  
  def edit
    
    if $facebook.is_guest
      render :json=>{:ok=>false, :error_message=>MUST_LOGIN_ERROR}
      return
    end
    
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    
    if !@figure.active?
      render :json=>{:ok=>false,:error_message=>"This figure is not valid anymore because it is deleted by admin."}
      return
    end
    
    params[:title_us] = params[:title_us].split(' ').map{|t| t.capitalize}.join(' ') if params[:title_us]
    
    languages = Language.all()
    languages.each do |language|
      @figure["title_"+language.code.downcase] = params[("title_"+language.code.downcase).to_sym] if params[("title_"+language.code.downcase).to_sym]
    end
    
    @figure.description = params[:description] if params[:description]
    
    @figure.update_figure_tag(params[:tags]) if params[:tags]
    @figure.tags = @figure.get_tags_column
    if !@figure.save
      render :json=>{:ok=>false, :error_message=>format_error(@figure.errors)}
      return
    end

    render :json=>{:ok=>true,:figure=>@figure,:title=>@figure.title,:tag_text=>(render_to_string :partial=>"figure/edit_tag", :locals=>{:figure=>@figure})}
  end
  
  def delete
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    
    if !@figure.active?
      render :json=>{:ok=>false,:error_message=>"This figure is not valid anymore because it is deleted by admin."}
      return
    end
    
    @figure.status = Figure::STATUS_DELETED
    
    if !@figure.save
      render :json=>{:ok=>false, :error_message=>format_error(@figure.errors)}
      return
    end
    
    FigureTag.delete_all(["figure_id=?",@figure.id])
    
    render :json=>{:ok=>true}
  end
  
  def view
    connection = ActiveRecord::Base.connection();
    @figure = Figure.first(:conditions=>{:id => params[:id]})
    
    if !@figure.active?
      render :json=>{:ok=>false,:error_message=>"This figure is not valid anymore because it is deleted by admin."}
      return
    end
    
    connection.execute("UPDATE `figures` SET `views` = `views` + '1' WHERE `id`='"+ @figure.id.to_s + "'")
  end
  
  def change_love_anonymity
    figure_love = FigureLove.first(:conditions=>{:id => params[:figure_love_id]})
    figure_love.is_anonymous = ((params[:is_anonymous]=="yes")?true:false)
    figure_love.save
    
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"profile/public_hidden_status",:locals=>{:figure_love=>figure_love})}
  end
  
  def index
    if $facebook.is_guest
      render :not_login
    end
  end
  

  def get_next

    if !$member.is_guest

#      Lock.generate("Love",$member.facebook_id,params[:current_figure_id]).synchronize {
#        figure_love = FigureLove.first(:conditions=>{:figure_id=>params[:current_figure_id],:facebook_id=>$member.facebook_id})
#        if !figure_love
#          FigureLove.create(:figure_id=>params[:current_figure_id],
#                            :facebook_id=>$member.facebook_id,
#                            :love_type=>FigureLove::TYPE_DONT_CARE,
#                            :created_date=>Time.now)
#        end
#      }
    end

    figure_ = nil
    if params[:figure_id] and params[:figure_id].to_i > 0
      figure = Figure.first(:conditions=>{:id=>params[:figure_id],:status=>Figure::STATUS_ACTIVE})
    end

    if !figure
      excluded_ids = []
      excluded_ids = params[:excluded_ids].split(',') if params[:excluded_ids]
      figure = get_suggested_figures(1,excluded_ids)
    end

    # render add page
    if !figure
      if $facebook.is_guest
        render :json=>{:ok=>true,:end=>true,:html=>(render_to_string :partial=>"figure/not_login")}
      else
        render :json=>{:ok=>true,:end=>true,:html=>(render_to_string :partial=>"figure/add_page")}
      end
      
      return
    end


    render :json=>{:ok=>true,:figure_id=>figure.id,:html=>(render_to_string :partial=>"figure/view_page",:locals=>{:figure=>figure})}

  end

  def love


    if $facebook.is_guest
      pending = FigureLovePending.new
      pending.status = FigureLovePending::STATUS_PENDING
      pending.data = ActiveSupport::JSON.encode({:figure_id=>params[:figure_id],:type=>params[:type]})
      pending.save
      
      render :json=>{:ok=>true,:redirect_url=>"https://www.facebook.com/dialog/oauth?client_id=#{APP_ID}&redirect_uri=#{CGI.escape('http://'+DOMAIN_NAME+'/figure_love_pending/'+pending.unique_key)}"}  

      return
    end
    
    ok,@figure,error_message = inner_love(params[:figure_id].strip,params[:type])

    if ok
      render :json => {:ok=>true,
                        :credits=>$facebook.credits,
                        :previous_credits=>$facebook[:previous_credits],
                        :suggested_unit=>(render_to_string :partial=>"figure/suggested_unit", :locals=>{:figure=>@figure}),
                        :search_result_unit=>(render_to_string :partial=>"search/search_result_unit", :locals=>{:figure=>@figure}),
                        :thumbnail_unit=>(render_to_string :partial=>"home/thumbnail_unit", :locals=>{:figure=>@figure}),
                        :love_meter=>(render_to_string :partial=>"figure/love_meter", :locals=>{:figure=>@figure}),
                        :manager_love=>(render_to_string :partial=>"figure/manager_love", :locals=>{:figure=>@figure})
                      }
    else
      render :json =>{:ok=>false,:error_message=>error_message}
    end
  end
  
  def image_like

    render :json=>{:ok=>false,:error_message=>MUST_LOGIN_ERROR} \
      and return if $facebook.is_guest

    @figure_image = FigureImage.first(:conditions=>{:id => params[:figure_image_id]})
    
    @figure = Figure.first(:conditions=>{:id => @figure_image.figure_id})
    if !@figure.active?
      render :json=>{:ok=>false,:error_message=>"This figure is not valid anymore because it is deleted by admin."}
      return
    end

    render :json=>{:ok=>false,:error_message=>"Image does not exist."}\
      and return if !@figure_image

    Lock.generate("FigureImage",$member.facebook_id,@figure_image.id).synchronize {
      @figure_image_like = FigureImageLike.first(:conditions=>{:figure_image_id=>@figure_image.id,:facebook_id=>$member.facebook_id})

      if !@figure_image_like
        @figure_image_like = FigureImageLike.new
        @figure_image_like.figure_image_id = @figure_image.id
        @figure_image_like.facebook_id = $member.facebook_id
      end

      @figure_image_like.is_anonymous = $is_anonymous

      if @figure_image_like.like_type == params[:type]
        @figure_image_like.save
        render :json => {:ok=>true,:likes=>@figure_image.likes,:dislikes=>@figure_image.dislikes,:type=>@figure_image_like.like_type}
        return
      end
      
#      $facebook.add_credit(POINT_VOTE_IMAGE)

      if @figure_image_like.like_type == FigureImageLike::TYPE_LIKE
        ActiveRecord::Base.connection.execute("UPDATE `figure_images` SET `likes` = `likes` - '1' WHERE `id`='"+ @figure_image.id.to_s + "'")
      elsif @figure_image_like.like_type == FigureImageLike::TYPE_DISLIKE
        ActiveRecord::Base.connection.execute("UPDATE `figure_images` SET `dislikes` = `dislikes` - '1' WHERE `id`='"+ @figure_image.id.to_s + "'")
      end

      if params[:type] == FigureImageLike::TYPE_LIKE
        ActiveRecord::Base.connection.execute("UPDATE `figure_images` SET `likes` = `likes` + '1' WHERE `id`='"+ @figure_image.id.to_s + "'")
      elsif params[:type] == FigureImageLike::TYPE_DISLIKE
        ActiveRecord::Base.connection.execute("UPDATE `figure_images` SET `dislikes` = `dislikes` + '1' WHERE `id`='"+ @figure_image.id.to_s + "'")
      end

      @figure_image_like.like_type = params[:type]

      if params[:type] != FigureImageLike::TYPE_CANCEL
        @figure_image_like.created_date = Time.now
      end

      @figure_image_like.save
      
      Feed.create_feed(@figure_image_like)
    }

    @figure = Figure.first(:conditions=>{:id=>@figure_image.figure_id})
    @figure.set_default_image
    
    @figure_image = FigureImage.first(:conditions=>{:id => params[:figure_image_id]})

    render :json => {:ok=>true,:credits=>$facebook.credits,:previous_credits=>$facebook[:previous_credits],:html=>(render_to_string :partial=>"figure/image_vote_panel",:locals=>{:image=>@figure_image})}
  end

  def get_image_vote_panel
    @figure_image = FigureImage.first(:conditions=>{:id=>params[:figure_image_id]})
    render :json => {:ok=>true,:html=>(render_to_string :partial=>"figure/image_vote_panel",:locals=>{:image=>@figure_image})}
  end

  def resize_all_images

    Delayed::Job.enqueue BatchImageResizer.new
    render :text=>"Done"
  end
  
  def share_feeling
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    scope = []
    scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
    result = {}
    
    if $facebook.is_guest
      result[:ok] = false
      result[:error_id] = FacebookCache::ERROR_NO_PERMISSION
    else
      @figure_love = FigureLove.first(:conditions=>{:figure_id => params[:figure_id],:facebook_id=>$facebook.facebook_id})
      result = $facebook.publish_feeling(@figure,@figure_love)
    end
    
    if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
  
      ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>"share feeling figure" + @figure.id.to_s) 
      
      return_url = "http://"+DOMAIN_NAME+"/figure/share_after_add/"+@figure.id.to_s+"/"+ticket.unique_key
      redirect_url = generate_permission_url(scope,return_url)
      
      render :json=>{:ok=>true,:figure_id=>@figure.id,:redirect_url=>redirect_url}
      return
    else
      ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_COMPLETED,
                                  :error_message=>"",
                                  :ref=>"share feeling figure" + @figure.id.to_s) 
                                  
      render :json=>{:ok=>true}
    end
     
 end
 
 def share_after_add
   
    @figure = Figure.first(:conditions=>{:id => params[:figure_id]})
    @figure_love = FigureLove.first(:conditions=>{:figure_id => params[:figure_id],:facebook_id=>$facebook.facebook_id})
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = $facebook.publish_feeling(@figure,@figure_love)
 
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
     
    redirect_to   @figure.get_url
   
 end
 
end
