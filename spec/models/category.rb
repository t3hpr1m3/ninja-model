class Category < NinjaModel::Base
  attribute :id, :integer, :primary_key => true
  attribute :post_id, :integer
  attribute :name, :string

  belongs_to :post
end
