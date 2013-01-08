require 'spec_helper'

describe ApplicationController do
  describe '#cors' do
    before(:each) do
    end

    it 'should set the access-control-allow-origin header' do
      #expect(@response.headers['Access-Control-Allow-Origin']).to eq('http://build.zooniverse.org')
    end

    it 'should set the access-control-allow-methods header' do
      #expect(@response.headers['Access-Control-Allow-Methods']).to eq(%w(GET POST PUT DELETE OPTIONS))
    end

    it 'should set the access-control-allow-credentials header' do
      #expect(@response.headers['Access-Control-Allow-Credentials']).to eq('true')
    end

    it 'should set the access-control-allow-headers header' do
      #expect(@response.headers['Access-Control-Allow-Headers']).to eq(%w(Origin Accept Content-Type X-Requested-With))
    end
  end
end
