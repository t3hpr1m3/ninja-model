require 'spec_helper'

describe NinjaModel::Associations::BelongsToAssociation do
  let(:user) { FactoryGirl.create(:user) }
  let(:post) { FactoryGirl.create(:post, user_id: user.id) }

  context 'with an ActiveRecord parent' do
    describe 'accessing the association directly' do
      it 'should return an instance' do
        post.user.should eql(user)
      end
    end

    describe 'assigning an instance' do
      it 'should update the associated id' do
        post.user = user
        post.user_id.should eql(user.id)
      end
    end

    it 'should raise an exception when trying to assign the wrong class' do
      lambda { post.user = Tag.new }.should raise_error
    end
  end

  context 'with a NinjaModel parent' do
    context 'and an ActiveRecord child' do
      describe 'accessing the association directly' do
        it 'should trigger a fetch' do
          NinjaModel::Relation.any_instance.expects(:to_a).returns(post)
          t = Tag.new(post_id: post.id)
          t.post
        end

        it 'should assign the proper predicates' do
          t = Tag.new(post_id: post.id)
          predicates = t.association(:post).scoped.predicates
          predicates.count.should eql(1)
          predicates.first.attribute.should eql(:id)
          predicates.first.meth.should eql(:eq)
          predicates.first.value.should eql(post.id)
        end
      end
    end

    context 'and a NinjaModel child' do
      describe 'accessing the association directly' do
        it 'should trigger a fetch' do
          NinjaModel::Relation.any_instance.expects(:to_a).returns(post)
          c = Category.new(post_id: post.id)
          c.post
        end

        it 'should assign the proper predicates' do
          c = Category.new(post_id: post.id)
          predicates = c.association(:post).scoped.predicates
          predicates.count.should eql(1)
          predicates.first.attribute.should eql(:id)
          predicates.first.meth.should eql(:eq)
          predicates.first.value.should eql(post.id)
        end
      end
    end

    it 'should raise an exception when trying to assign the wrong class' do
      t = Tag.new
      lambda { t.post = user }.should raise_error
    end

    it 'should properly update the ids when assigning a new instance' do
      t = FactoryGirl.create(:tag)
      t.post = post
      t.post_id.should eql(post.id)
    end
  end
end
