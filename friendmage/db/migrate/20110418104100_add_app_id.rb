class AddAppId < ActiveRecord::Migration
  def self.up
    add_column :apps, :app_id, :string
    App.create({
    :name=>"Friends Poster",
    :desc=>"Friends Poster",
    :app_id=>"FriendPoster"
    })
     App.create({
    :name=>"Birthday Calendar",
    :desc=>"Birthday Calendar",
    :app_id=>"BirthdayCalendar"
    })
  end

  def self.down
  end
end
