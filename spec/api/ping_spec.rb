require 'spec_helper'

describe Comotion::API do

  def app
    Comotion::API
  end

  describe Comotion::Ping do
    it 'goes ping' do
      get '/ping'
      expect(last_response.status).to eq(200)
    end
  end
end
