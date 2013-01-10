require 'spec_helper'

describe SessionsController do

  describe "#create" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      User.should_receive(:find_or_create_from_omniauth).and_return(@user)
      controller.stub!(:auth_hash).and_return({ :some => 'hash'})
      controller.stub!(:set_session)
    end

    it 'should call find_or_create on Users' do
      post :create
    end

    it 'should redirect to /' do
      post :create
      expect(response).to redirect_to '/'
    end
  end

end
