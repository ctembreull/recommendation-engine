require 'spec_helper'

describe MyApp::API do

  def app
    MyApp::API
  end

  describe MyApp::Ping do
    it 'goes ping' do
      get '/ping'
      expect(last_response.status).to eq(200)
    end
  end
end
