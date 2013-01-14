require 'spec_helper'

describe UsersController do

  describe "#index" do
    describe 'logged in' do
      before(:each) do
        User.should_receive(:find).and_return(FactoryGirl.create(:user))
        session[:user_id] = 1
        get :index
      end

      it 'should get the current_user' do
        expect(assigns(:current_user)).to be_a(User)
      end

      it 'should return the current user' do
        expect(json_response['name']).to eq("MyString")
      end

      it 'should return ok' do
        expect(response).to be_success
      end
    end

    describe 'logged out' do
      it 'should return not authorized' do
        session[:user_id] = nil
        get :index
        expect(response.status).to eq(401)
      end
    end
  end

end