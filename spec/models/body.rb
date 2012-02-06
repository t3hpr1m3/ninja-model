class Body < NinjaModel::Base
  attribute :id, :integer, :primary_key => true
  attribute :post_id, :integer
  attribute :text, :string

  belongs_to :post
end
