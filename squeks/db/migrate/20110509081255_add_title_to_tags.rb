class AddTitleToTags < ActiveRecord::Migration
  def self.up
      add_column :figure_tags,:title_us,:string
      add_column :figure_tags,:title_th,:string
      add_column :figure_tags,:title_jp,:string
      add_column :figure_tags,:title_kr,:string
      add_column :figure_tags,:title_cn,:string
  end

  def self.down
      remove_column :figure_tags,:title_us
      remove_column :figure_tags,:title_th
      remove_column :figure_tags,:title_jp
      remove_column :figure_tags,:title_kr
      remove_column :figure_tags,:title_cn
  end
end
