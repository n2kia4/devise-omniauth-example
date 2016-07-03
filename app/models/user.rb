class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  has_many :identities, dependent: :destroy

  validates :name, presence: true

  def self.new_with_session(params,session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"],without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.from_omniauth(auth, current_user, signed_in_resource = nil)
    identity = Identity.find_for_oauth(auth)
    user = signed_in_resource ? signed_in_resource : identity.user
    if identity.user.nil?
      user = current_user || User.where('email = ?', auth["info"]["email"]).first
      if user.nil?
        user = User.new
        user.name = auth.info.name
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,10]
        if auth.provider == 'twitter'
          user.email = User.dummy_email(auth)
        end
        user.save
      end
    end
    if identity.user != user
      identity.user = user
      identity.save
    end
    user
  end

  private

  def self.dummy_email(auth)
    "#{auth.uid}-#{auth.provider}@example.com"
  end
end
