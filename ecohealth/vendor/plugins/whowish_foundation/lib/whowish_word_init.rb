

## define schema for words
begin 
  ActiveRecord::Schema.define do
  
    create_table "whowish_words", :force => false do |t|
      t.string "word_id", :null => false
      t.text  "content", :null => false
    end

  end

  add_index :whowish_words, :word_id, :unique => true

rescue
  #do nothing
end

## define schema for emails
begin
  ActiveRecord::Schema.define do

    create_table "whowish_word_emails", :force => false do |t|
      t.string "word_id", :null => false
      t.text  "content", :null => false
    end

  end

  add_index :whowish_word_emails, :word_id, :unique => true

rescue
  #do nothing
end

## define schema for facebooks
begin
  ActiveRecord::Schema.define do

    create_table "whowish_word_facebooks", :force => false do |t|
      t.string "publish_id",     :null => false
      t.string  "message", :null => false
      t.string  "name", :null => false
      t.string  "caption", :null => false
      t.text  "description", :null => false
    end

  end

  add_index :whowish_word_facebooks, :publish_id, :unique => true

rescue
  #do nothing
end

# extend Rails
require 'app/models/whowish_word'
require 'app/controllers/whowish_word_controller'

class ActionController::Base
  
  def choose_locale
    
    $locale = "en"
    $locale = session[:whowish_locale].downcase.strip if session[:whowish_locale]
    $locale = params[:whowish_locale].downcase.strip if params[:whowish_locale]
    
    session[:whowish_locale] = $locale
    
    logger.debug { "locale=#{$locale}"}
    
  end
  
end

class ActionView::Base
  
  @@whowish_word = {}
  
  def self.whowish_word
    @@whowish_word
  end

  def self.init_whowish_word

    words = WhowishWord.all() + WhowishWordEmail.all()
    
    @@whowish_word = {}
    words.each { |word|
      @@whowish_word[word.word_id] = word.content
    }
  end
  
  def self.whowish_word_for(page_id,id,*p)
    
    $locale = "en" if !$locale

    word_id = WhowishWord.generate_word_id(page_id,id,$locale)

    css = "cursor:pointer;\
          position:absolute;\
          left:0px;\
          top:-15px;\
          width:15px;\
          height:18px;";
          
    js_arg = []
    
    content = "##{id}(#{$locale})".downcase
    if @@whowish_word[word_id]
      
      content = "#{@@whowish_word[word_id]}"
      
     if p.length > 0
        p = p[0]

        p.each_pair { |key,val|
          content.gsub!("{#{key}}","#{val}")
          js_arg.push("\"#{key}\":\"#{val.to_s.gsub('"','\\"')}\"")
        }
      end
  
    end

    

    if !$whowish_word_admin
      return content
    elsif  id.to_s.match("default") or id.to_s.match("whowish_box_title")
      
      edit = "<span style='"+css+"' onclick=\"change_whowish_word(this,'#{word_id}',{},arguments[0] );return false;\"><img src='/whowish_foundation_asset/edit_icon.gif'/></span>"

      
      return content.gsub("\"", "\"")+"\",({whowish_word_class:\"#{word_id}\",edit:\"" + edit.gsub('"', '\\"') + "\"}),\""
    else
      
      arg_id = "whowish_word_arg_" + word_id.gsub('.','_').gsub('/','__')
      
      edit = "<span style='"+css+"' onclick=\"change_whowish_word(this,'#{word_id}',{},arguments[0] );return false;\"><img src='/whowish_foundation_asset/edit_icon.gif'/></span>"

      
      return "<span style='position:relative;'><span class='#{word_id}'>" + content + "</span>" + edit + "</span>"
    end
    
  end

  def word_for(id, *p)
    ActionView::Base.whowish_word_for(template.to_s,id,*p)
  end
end

# init all words
ActionView::Base.init_whowish_word

class ActionMailer::Base
  
  def word_for(id, *p)
    ActionView::Base.whowish_word_for(mailer_name + "/" + @template+".html.erb",id,*p)
  end
end

# load all controllers, helpers, and models
%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.load_paths.insert(0, path)
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActionController::Base.append_view_path(RAILS_ROOT+"/vendor/plugins/whowish_foundation/lib/app/views")

# add routes
class << ActionController::Routing::Routes;self;end.class_eval do
  define_method :clear!, lambda {}
end

ActionController::Routing::Routes.draw do |map|
  map.connect 'whowish_word/:action', :controller => 'whowish_word'
  map.connect 'whowish_word_email/:action', :controller => 'whowish_word_email'
  map.connect 'whowish_word_facebook/:action', :controller => 'whowish_word_facebook'
end