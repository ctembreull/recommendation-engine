module Comotion
  # Canary class; used to test connectivity
  class Ping < Grape::API
    get :ping do
      {ping: 'pong'}
    end
  end
end
