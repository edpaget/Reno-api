require 'spec_helper'

describe DeleteTarball do
  before(:each) do
    @deploy = FactoryGirl.create(:deploy)
    Deploy.stub!(:find).and_return(@deploy)
  end

  describe '::perform' do
  end
end
