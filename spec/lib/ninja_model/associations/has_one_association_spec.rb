require 'spec_helper'

describe NinjaModel::Associations::HasOneAssociation do
  let(:user) { Factory(:user) }
  let(:post) { Factory(:post, :user_id => user.id) }
  let(:bio) { Factory(:bio, :user_id => user.id) }

  context 'with an ActiveRecord parent' do
    describe 'accessing the association directly' do
      it 'should trigger a fetch' do
        NinjaModel::Relation.any_instance.expects(:to_a).returns([bio])
        user.bio.name.should eql(bio.name)
      end
    end

    it 'should assign the proper predicates' do
      predicates = user.association(:bio).scoped.predicates
      predicates.count.should eql(1)
      predicates.first.attribute.should eql(:user_id)
      predicates.first.meth.should eql(:eq)
      predicates.first.value.should eql(user.id)
    end
  end

  context 'with a NinjaModel parent' do
    context 'and an ActiveRecord child' do
      let!(:email_address) { Factory(:email_address, :bio_id => bio.id) }
      describe 'accessing the association directly' do
        it 'should retrieve the record' do
          bio.email_address.should be_kind_of(EmailAddress)
        end
      end

      it 'should allow building the association' do
        email = bio.build_email_address
        email.should be_kind_of(EmailAddress)
        email.bio_id.should eql(bio.id)
      end

      it 'should allow creating the association' do
        bio.create_email_address(:email => 'foo@bar.com').should be_true
      end
    end

    context 'and a NinjaModel child' do
      let(:body) { Factory(:body, :post_id => post.id) }
      describe 'accessing the association directly' do
        it 'should trigger a fetch' do
          NinjaModel::Relation.any_instance.expects(:to_a).returns([body])
          post.body
        end

        it 'should assign the proper predicates' do
          predicates = post.association(:body).scoped.predicates
          predicates.count.should eql(1)
          predicates.first.attribute.should eql(:post_id)
          predicates.first.meth.should eql(:eq)
          predicates.first.value.should eql(post.id)
        end
      end

      it 'should allow building the association' do
        #
        # We have to stub to_a here because building will try and retrieve the
        # existing record to remove ownership
        #
        NinjaModel::Relation.any_instance.stubs(:to_a).returns([])
        body = post.build_body
        body.should be_kind_of(Body)
        body.post_id.should eql(post.id)
      end

      it 'should allow creating the association' do
        NinjaModel::Relation.any_instance.stubs(:to_a).returns([])
        Body.any_instance.stubs(:create).returns(true)
        post.create_body(:text => 'Foobar')
      end
    end
  end
end
