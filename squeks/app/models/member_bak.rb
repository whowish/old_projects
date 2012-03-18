class MemberBak
  include FacebookHelper
  attr_accessor :facebook_id,
                :friend_ids,
                :crpytoid,
                :anonymity

  def is_guest
    (@cryptoid == nil)
  end

  def self.get_guest
    MemberBak.new
  end

  def initialize(facebook_data=nil)
    return if facebook_data == nil

    json_data = ActiveSupport::JSON.decode facebook_data
    @facebook_id = json_data['id']

    crypto_key = MemberBak::generate_crypto_key(@facebook_id)
    anonymity_key = MemberBak::generate_anonymity_key(@facebook_id)

    @cryptoid = Member.first(:conditions=>{:key=>crypto_key})
    @cryptoid = Member.create(:key=>crypto_key,
                    :name=>json_data['name'],
                    :gender=>(json_data['gender'] or "male"),
                    :profile_pic=>"") if @cryptoid == nil

    @anonymity = Anonymity.first(:conditions=>{:key=>anonymity_key})
    @anonymity =Anonymity.create(:key=>anonymity_key,
                    :name=>"John Doe",
                    :gender=>(json_data['gender'] or "male"),
                    :profile_pic=>"") if @anonymity == nil

    @friend_ids = nil
    friends
  end

  def gender
    return "male" if !@cryptoid
    @cryptoid.gender
  end

  def name
    return "Guest" if !@cryptoid
    @cryptoid.name
  end

  def anonymity_name
    return "Guest" if !@anonymity
    @anonymity.name
  end

  def profile_pic
    return "" if !@cryptoid
    @cryptoid.profile_pic
  end

  def anonymity_profile_pic
    return "" if !@anonymity
    @anonymity.profile_pic
  end


  def member_ids
    ids = []
    ids.push(@cryptoid.id) if @crypto
    ids.push(@anonymity.id) if @anonymity

    ids
  end

  def crypto_key
    @cryptoid.key
  end

  def anonymity_key
    @anonymity.key
  end

  def crypto_id
    @cryptoid.id
  end

  def anonymity_id
    @anonymity.id
  end

  def friends

    return [] if is_guest

    get_friends(@facebook_id,crypto_id)
  end

  def get_friends(facebook_id,crypto_id,force_update=false,get_remote=true)

    return [] if !facebook_id

    friend = FriendCache.first(:conditions=>{:crypto_id=>crypto_id})

    if get_remote and (!friend or force_update)
      friend = FriendCache.new(:crypto_id=>crypto_id,:updated_date=>Time.now) if !friend
      result_data = get_data("friends",facebook_id)

      begin
        data = ActiveSupport::JSON.decode(result_data)["data"]

        crypto_keys = []
        anonymity_keys = []

        data.each{ |i|
           crypto_keys.push(MemberBak::generate_crypto_key(i["id"]))
           anonymity_keys.push(MemberBak::generate_anonymity_key(i["id"]))
        }

        friend.friends = (Member.all(:conditions=>{:key=>crypto_keys}).map{ |i| i.id.to_s } + \
                          Anonymity.all(:conditions=>{:key=>anonymity_keys}).map{ |i| i.id.to_s }).join(',')


      rescue Exception=>e
        print "\n\n\n\n" + e + "\n\n\n\n"
      end

      friend.updated_date = Time.now
      friend.save
    end

    return [] if !friend

    if !force_update and (Time.now - friend.updated_date) > 60*60*24
      #schedule update job
      Delayed::Job.enqueue AsyncFriendCache.new(facebook_id,crypto_id,$oauth_token)
    end

    return (friend.friends.split(',') rescue [])
  end

  def self.generate_anonymity_key(facebook_id)
    require 'digest/md5'
    signature = Digest::MD5.hexdigest("ANONYMITY"+facebook_id+"ANONYMITY")

    some_str = ""
    some_str = facebook_id[-4..-3] if facebook_id.length >= 4
    return "A"+some_str+"|"+signature
  end

  def self.generate_crypto_key(facebook_id)
    require 'digest/md5'
    signature = Digest::MD5.hexdigest("CRYPTO"+facebook_id+"CRYPTO")

    some_str = ""
    some_str = facebook_id[-2..-1] if facebook_id.length >= 4
    return "F"+some_str+"|"+signature
  end
end
