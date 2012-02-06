require 'spec_helper'

describe NinjaModel::Associations::HasManyAssociation do
  let(:user) { Factory(:user) }

  describe 'accessing the association directly' do
    it 'should return a CollectionProxy' do
      user.posts.should be_kind_of(NinjaModel::Associations::CollectionProxy)
    end
  end

  describe 'adding a scope' do
    it 'should return a NinjaModel::Relation' do
      user.posts.published.should be_kind_of(NinjaModel::Relation)
    end
    it 'should have the correct predicates' do
      predicates = user.posts.published.predicates
      predicates.count.should eql(2)

      predicates.first.attribute.should eql(:user_id)
      predicates.first.meth.should eql(:eq)
      predicates.first.value.should eql(user.id)

      predicates.last.attribute.should eql(:published)
      predicates.last.meth.should eql(:eq)
      predicates.last.value.should eql(true)
    end
  end

  describe 'building an associated object' do
    it 'should return an unitialized object' do
      user.posts.build.should be_kind_of(Post)
    end
    it 'should already belong to the user' do
      user.posts.build.user.should eql(user)
    end
  end
end
