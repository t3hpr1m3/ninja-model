require 'spec_helper'

describe NinjaModel::Associations::HasManyAssociation do
  let(:user) { FactoryGirl.create(:user) }

  context 'with an ActiveRecord parent' do

    describe 'accessing the association directly' do
      it 'should return a CollectionProxy' do
        user.posts.should be_kind_of(NinjaModel::Associations::CollectionProxy)
      end
    end

    describe 'first' do
      it 'should trigger a fetch' do
        NinjaModel::Relation.any_instance.expects(:to_a).returns([])
        user.posts.first.should
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
        user.posts.build.user.id.should eql(user.id)
      end
    end
  end

  context 'with a NinjaModel parent' do

    let(:post) { FactoryGirl.create(:post) }
    let!(:tags) { FactoryGirl.create_list(:tag, 2, post_id: 1) }

    context 'and an ActiveRecord association' do
      it 'should return an Array' do
        post.tags.should be_kind_of(Array)
      end

      it 'should retrieve the proper associated objects' do
        post.tags.count.should be > 0
      end

      it 'should allow chaining queries' do
        post.tags.where(name: 'Tag 2').count.should eql(1)
      end

      describe 'building an associated object' do
        it 'should return an unitialized object' do
          post.tags.build.should be_kind_of(Tag)
        end
        it 'should already belong to the Post' do
          post.tags.build.post_id.should eql(post.id)
        end
      end
    end

    context 'and a NinjaModel association' do
      it 'should return a CollectionProxy' do
        post.categories.should be_kind_of(NinjaModel::Associations::CollectionProxy)
      end

      it 'should assign the proper predicates' do
        predicates = post.categories.scoped.predicates
        predicates.count.should eql(1)
        predicates.first.attribute.should eql(:post_id)
        predicates.first.meth.should eql(:eq)
        predicates.first.value.should eql(1)
      end

      it 'should allow chaining' do
        predicates = post.categories.where(name: 'foo').predicates
        predicates.count.should eql(2)
        predicates.first.attribute.should eql(:post_id)
        predicates.first.meth.should eql(:eq)
        predicates.first.value.should eql(1)
        predicates.last.attribute.should eql(:name)
        predicates.last.meth.should eql(:eq)
        predicates.last.value.should eql('foo')
      end

      describe 'accessing the collection' do
        it 'should trigger a fetch' do
          NinjaModel::Relation.any_instance.expects(:to_a).returns([])
          post.categories.count
        end
      end

      describe 'building an associated object' do
        it 'should return an unitialized object' do
          post.categories.build.should be_kind_of(Category)
        end
        it 'should already belong to the user' do
          post.categories.build.post_id.should eql(post.id)
        end
      end
    end
  end
end
