class Bio < NinjaModel::Base
  attribute :id, :integer
  attribute :user_id, :integer
  attribute :name, :string

  belongs_to :user
  has_one :email_address
end
