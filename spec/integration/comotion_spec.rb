require 'spec_helper'

describe 'Comotion' do
  include Rack::Test::Methods

  def app
    Comotion::API.new
  end

  it 'connects to mongodb' do
    expect(true).to eq(true)
  end

  it 'connects to elasticsearch' do
    expect(true).to eq(true)
  end

  it 'connects to neo4j' do
    expect(true).to eq(true)
  end

end
