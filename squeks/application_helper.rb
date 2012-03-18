# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include FacebookHelper
  include Foundation
  include ThumbnailismHelper
  include NotificationHelper
  
  def truncate_bytes(string, size)
    count = 0
    string.chars.take_while{|c| (count += c.bytes.to_a.length) <= size }.join
  end
  
  def highlight_censor(a,b)
    as = [], bs = []
    
    as.push(' ')
    bs.push(' ')
    
    a.chars { |c| as.push(c)}
    b.chars { |c| bs.push(c)}
    
    as.push(' ')
    bs.push(' ')
    
    as,bs = bs,as if bs.length > as.length
    
    d = []
    as.length.times { 
      row = []
      bs.length.times { row.push(10000000000000000) }
      d.push(row)
    }
    
    # base case
    d[0][0] = 0
    d[0][0] = 1 if as[0] != bs[0]
    
    (as.length-1).times { |i|
      i += 1
      d[i][0] = i + 1 
    }
    
    (bs.length-1).times { |j| 
        j += 1
        d[0][j] = j + 1 
    }
    
    (as.length-1).times { |i|
      i += 1
      (bs.length-1).times { |j| 
        j += 1
        
        d[i][j] = d[i-1][j-1]  + ((as[i]==bs[j])?0:1);
        
        (0..j-2).times { |k|
          d[i][j] = [d[i-1][k]+(j-k),d[i][j]].min
        }
        
        (0..i-2).times { |k|
          d[i][j] = [d[k][j-1]+(i-k),d[i][j]].min
        }
      }
    }
    
  end

  
  def get_member_info(facebook_id)
    member = Member.first(:conditions=>{:facebook_id=>facebook_id})
    
    member.set_facebook_cache(get_facebook_info(member.facebook_id))

    member
  end

  def get_suggested_figures(max,excluded_ids=[])

    logger.debug {"Enter get_suggested_figures()"}
    logger.debug {"max=#{max}"}
    logger.debug {"excluded_ids=#{excluded_ids}"}

    suggested_figure_ids = [0]
    figures = []
    member_loves = []

    if !$member.is_guest
      loves = FigureLove.all(:select =>"figure_id,COUNT(1) AS num",:conditions=>["facebook_id in (?) AND NOT(facebook_id=?) AND NOT(love_type=?)",$member.all_friends,$member.facebook_id,FigureLove::TYPE_DONT_CARE],:group=>"figure_id",:limit=>max,:order=>"num DESC")

      loves.each { |o|
        suggested_figure_ids.push(o.figure_id)
      }

      member_loves = FigureLove.all(:select =>"figure_id",:conditions=>["facebook_id=?",$member.facebook_id])

      figures = Figure.all(:conditions=>["id IN (:ids) AND id NOT IN (:excluded_ids) AND status=:status",{:ids=>suggested_figure_ids,:excluded_ids=>excluded_ids + member_loves,:status=>Figure::STATUS_ACTIVE}],:limit=>max,:order=>"rand()")
    end



    if figures.length < max
      figures = figures + Figure.all(:conditions=>["id NOT IN (?) AND status=?",member_loves.map { |o| o.figure_id} + suggested_figure_ids+excluded_ids,Figure::STATUS_ACTIVE],:order=>"rand()",:limit=>(max-figures.length))
    end

    if figures.length < max
      member_loves = FigureLove.all(:select =>"figure_id",:conditions=>["facebook_id=? AND NOT(love_type=?)",$member.facebook_id,FigureLove::TYPE_DONT_CARE])
      figures = figures + Figure.all(:conditions=>["id NOT IN (?) AND status=?",member_loves.map { |o| o.figure_id} + suggested_figure_ids+excluded_ids,Figure::STATUS_ACTIVE],:order=>"rand()",:limit=>(max-figures.length))
    end

    if max == 1
      logger.debug {"Exit figure_id=#{figures[0].id}"} and return figures[0] if figures.length > 0
      logger.debug {"Exit figure=nil"} and return nil
    else
      logger.debug {"Exit figures=#{figures.map{|f|f.title}.join(',')}, length=#{figures.length}"} and return figures
    end

  end

  def calculate_love_hate_width(love_count,hate_count,total_width,min_width=nil)
    min_width = (total_width*2/100) if !min_width

    total_count = love_count + hate_count

    love_width = (total_count==0)?((total_width/2).to_i):((love_count.to_f * total_width / total_count.to_f).to_i)
    hate_width = total_width - love_width

    if love_width < min_width
      love_width = min_width
      hate_width = total_width - love_width
    elsif  hate_width < min_width
      hate_width = min_width
      love_width = total_width - hate_width
    end

    return love_width, hate_width
  end
  
  def get_tag_text(figure)
#    tags_name = []
#    figure_tags = FigureTag.all(:conditions=>{:figure_id=>figure.id})
#    figure_tags.each do |ft|
#      tag = Tag.first(:conditions=>{:id=>ft.tag_id})
#      tags_name.push(tag.name)
#    end
#    tags_name.uniq!
#    
#    return_text = "-"
#    return_text = tags_name.join(',') if tags_name.length > 0
    return_text = "-"
    return_text = figure.tags.gsub('</t><t>',', ').gsub(/<[\/]?t>/,'') if figure.tags and figure.tags != ""
    return return_text
  end
end
