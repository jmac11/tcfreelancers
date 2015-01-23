class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:linkedin]

  validates :twitter_handle, length: { maximum: 15 }, :allow_blank => true
  validates :description, length: { maximum: 280 }, :allow_blank => true
  validate :specialty_list_count

  acts_as_taggable_on :specialties

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.headline = auth.info.headline
      user.profile_url = auth.info.urls.public_profile
      user.profile_image = auth.info.image
    end
  end

  def specialty_list_count
    errors.add(:specialty_list, "only allows 5 specialties") unless specialty_list.count <= 5
  end
end
