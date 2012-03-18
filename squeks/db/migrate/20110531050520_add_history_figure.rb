class AddHistoryFigure < ActiveRecord::Migration
  def self.up
    rename_column :history_figures, :title,:title_us
    add_column :history_figures,:title_th, :string
    add_column :history_figures,:title_jp, :string
    add_column :history_figures,:title_kr, :string
    add_column :history_figures,:title_cn, :string
    add_column :history_figures,:tags, :text
    add_column :history_figures,:value, :integer,:default=>1,:null=>false
    add_column :history_figures,:manager_facebook_id, 'bigint', :default=>0,:null=>false
    add_column :history_figures,:creator_facebook_id, 'bigint', :default=>0,:null=>false
    add_column :history_figures,:bid_start_time, :datetime
    add_column :history_figures,:bid_status, :string,:default=>"SETTLED",:null=>false
    add_column :history_figures,:zip_file_path, :string
    add_column :history_figures,:country_code, :string
    
    add_column :history_comments,:total_agree, :integer
    add_column :history_comments,:status, :string
    
    add_column :history_figure_pictures,:ordered_number, :integer
    add_column :history_figure_pictures,:likes, :integer
    add_column :history_figure_pictures,:dislikes, :integer
    
    add_column :history_figure_tags,:title_us,:string
    add_column :history_figure_tags,:title_th,:string
    add_column :history_figure_tags,:title_jp,:string
    add_column :history_figure_tags,:title_kr,:string
    add_column :history_figure_tags,:title_cn,:string
  end

  def self.down
  end
end
