module Comotion
  # Default mounting point for API methods
  class API < Grape::API
    format :json

    before do; end
    after do; end
    helpers do
      def network_filter(in_user, params, results)
        matches = []
        results['hits']['hits'].each do |u|
          u['_network'] = {}
          include_doc   = true
          ['following', 'followers', 'wishlist', 'wish_met', 'friends'].map{ |key|
            u['_network'][key] = ((in_user['_source'][key] ||= []).include? u['_id']) ? true : false
            include_doc = false if (params["exclude_#{key}".to_sym] && u['_network'][key] == true)
          }

          matches << u if include_doc
        end

        if (params[:count] && params[:count] > 0)
          matches = matches.slice(0, params[:count])
          result['hits']['total'] = matches.length
          result['hits']['hits']  = matches
        else
          results['hits']['total'] = matches.length
          results['hits']['hits']  = matches
        end
        return results
      end
    end

    mount ::Comotion::Ping
    mount ::Comotion::Users::API
    mount ::Comotion::Groups::API
    mount ::Comotion::Events::API
    mount ::Comotion::Teams::API
    mount ::Comotion::Search::API

  end
end
