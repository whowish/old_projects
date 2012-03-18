class WhowishWordController < ActionController::Base
  
  before_filter :compact_policy,:check_whowish_word_admin
  before_filter :check_whowish_word_login, :except=>[:login,:do_login]
  
  def check_whowish_word_login
    
    render :login, :layout=>"blank" if session[:whowish_word_login] != "true"
  end
  
  def check_whowish_word_admin
    $whowish_word_admin = session[:whowish_word_admin]
  end
  
  def compact_policy
    response.headers['P3P'] = 'policyref="/w3c/p3p.xml", CP="'+COMPACT_POLICY+'"'
  end
  
  layout "whowish_word_blank"

  def do_login
    if params[:password] == "whowish#456"
      session[:whowish_word_login] = "true"
      index
      render :index
    else
      @error = "The password is invalid."
      render :login, :layout=>"blank"
    end
  end
  
  def logout
    session[:whowish_word_login] = nil
    render :login, :layout=>"blank"
  end

  def activate
    if params[:enabled]=="yes"
      session[:whowish_word_admin] = true
    else
      session[:whowish_word_admin] = false
    end
    
    render :json=>{:ok=>true}
  end


  SHOW_FIELDS = [{:id=>"page_name",:width=>75},
          {:id=>"page_id",:width=>150},
          {:id=>"word_id",:width=>100},
          {:id=>"content",:type=>"textarea"}]

  def index
    @fs = SHOW_FIELDS
  end
  
  def get_word
    entity = WhowishWord.first(:conditions=>{:page_id => params[:page_id].strip,:word_id=>params[:word_id].strip})
    
    render :json=>{:content=>""} and return if !entity
    render :json=>{:content=>entity.content}
  end

  def change_word

    entity = nil

    if params[:id]
      entity = WhowishWord.first(:conditions=>{:id => params[:id]})
    else
      entity = WhowishWord.first(:conditions=>{:page_id => params[:page_id].strip,:word_id=>params[:word_id].strip})
    end
    
    if !entity
      #render :json=>{:ok=>false,:error_message=>"Cannot find "+params[:page_id]+":"+params[:word_id]} and return 
      
      entity = WhowishWord.new
      entity.page_name = params[:page_id].strip
      entity.page_id = params[:page_id].strip
      entity.word_id = params[:word_id].strip
      entity.content = params[:content].strip
      entity.locale = "en"

    end

    entity.page_name = params[:page_name].strip if params[:page_name]
    entity.page_id = params[:page_id].strip
    entity.word_id = params[:word_id].strip
    entity.content = params[:content].strip
    entity.save
    
    ActionView::Base.whowish_word[entity.page_id] = {} if !ActionView::Base.whowish_word[entity.page_id]
    ActionView::Base.whowish_word[entity.page_id][entity.word_id.to_sym] = entity.content
    
    render :json=>{:ok=>true}
  end
  
  def add
    
    entity = WhowishWord.new
    entity.page_name = params[:page_name].strip
    entity.page_id = params[:page_id].strip
    entity.word_id = params[:word_id].strip
    entity.content = params[:content].strip
    entity.locale = "en"
    
    if !entity.save
      render :json => {:ok=>false, :error_message=>format_error(entity.errors)}
      return
    end
    
    render :json=>{:ok=>true ,:new_row=>render_to_string(:partial=>"row",:locals=>{:entity=>entity,:field_set=>SHOW_FIELDS,:is_new=>false}), :entity=> entity}
    
  end
  
  def delete

    if !WhowishWord.delete(params[:id])
      render :json=>{:ok=>false,:error_message=>"error while delete location"}
      return
    end
 
    render :json=>{:ok=>true}
  end
end