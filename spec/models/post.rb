class Post < NinjaModel::Base
  attribute :id, :integer, :primary_key => true
  attribute :user_id, :integer
  attribute :title, :string
  attribute :published, :boolean

  scope :published, where(:published => true)

  belongs_to :user
  has_one :body
  has_many :tags
  has_many :categories
end
