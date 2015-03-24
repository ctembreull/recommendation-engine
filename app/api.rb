module Comotion
  # Default mounting point for API methods
  class API < Grape::API
    format :json

    before do; end
    after do; end
    helpers do; end

    mount ::Comotion::Ping
    mount ::Comotion::Users::API
    mount ::Comotion::Groups::API
    mount ::Comotion::Events::API
    #mount ::Comotion::Recommendations

  end
end
