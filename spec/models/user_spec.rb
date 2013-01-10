require 'spec_helper'

describe User do
  it { should have_and_belong_to_many(:projects) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:uid) }
  it { should validate_presence_of(:oauth_token) }
  it { should validate_presence_of(:github_username) }

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  describe "::find_or_create_from_omniauth" do
    before(:each) do
      @auth_hash = { :provider => 'github',
                     :uid => 'MyString',
                     :info => { :name => 'edpaget',
                                :email => 'edpaget@example.com'},
                     :credentials => { :token => 'ajskd;flajsd;f' }}
    end

    it 'should return object if it already exists' do
      expect(User.find_or_create_from_omniauth(@auth_hash)).to eq(@user)
    end

    it 'should create a new user if one does not exist' do
      @auth_hash[:uid] = "SomethingCompletelyDifferent"
      User.should_receive(:create!).and_return(@user)
      User.find_or_create_from_omniauth(@auth_hash)
    end
  end

  describe "#changed_credentials?" do
    it 'should return true when credentials have changed from what was stored' do
      credentials = { :token => 'MyString1', :secret => 'MyString2' }
      expect(@user.changed_credentials?(credentials)).to be_true
    end

    it 'should return false if credentials have not changed' do
      credentials = { :token => 'MyString', :secret => 'MyString' }
      expect(@user.changed_credentials?(credentials)).to be_false
    end
  end
end
