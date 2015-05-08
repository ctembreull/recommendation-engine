module Comotion
  module Users
    class API < Grape::API
      @@type = 'person'

      rescue_from Elasticsearch::Transport::Transport::Errors::NotFound do |e|
        message = {
          status: 404,
          resource: e.message,
          error: 'Not Found'
        }
        Rack::Response.new([ message ], 404, { 'Content-Type' => 'application/json' }).finish
      end

      helpers do
        params :person do
          requires :person, type: Hash do
            requires :id,       type: String, allow_blank: false
            optional :email,    type: String
            optional :username, type: String
            optional :fullname, type: String
            optional :tags,     type: Array
            optional :avatar,   type: String
            optional :role,     type: String
          end
        end

        params :network do
          optional :exclude_following, type: Boolean, default: false
          optional :exclude_followers, type: Boolean, default: false
          optional :exclude_wishlist,  type: Boolean, default: false
          optional :exclude_wish_met,  type: Boolean, default: false
          optional :exclude_friends,   type: Boolean, default: false
          optional :count,             type: Integer
        end
      end # helpers

      namespace :users do

        # POST /users
        desc 'Create or replace a user'
        params do
          use :person
        end
        post do
          person = {}
          model  = Comotion::Data::Person::Model.new
          model.members.each do |field|
            person[field] = params[:person][field] unless params[:person][field].nil?
          end

          es = Comotion::Data::Elasticsearch.new(@@type)
          if es.exists(person[:id])
            response = es.update(person[:id], person)
          else
            response = es.index(person[:id], person)
          end

          return response
        end

        route_param :user_id do

          params do
            requires :user_id, type: String
          end

          # GET /users/:user_id
          desc 'Retrive a user object by id'
          get do
            response = Comotion::Data::Elasticsearch.new(@@type).document(params[:user_id])
          end

          desc 'Convenience endpoint for status update'
          params do
            requires :status, type: String, allow_blank: true
          end
          put :status do
            patch = { status: params[:status] }
            response = Comotion::Data::Elasticsearch.new(@@type).update(params[:user_id], patch)
          end

          desc 'Delete an existing user object'
          delete do
            response = Comotion::Data::Elasticsearch.new(@@type).delete(params[:user_id])
          end

          namespace :wishlist do

            # GET /users/:user_id/wishlist { mode=*all|met|unmet }
            desc 'get wishlist, optionally filtered by met|unmet status'
            get do
            end

            route_param :other_user_id do

              params do
                requires :other_user_id, type: String
              end

              # POST   /users/:user_id/wishlist/:other_user_id
              desc 'add a user to the wishlist'
              post do
                es   = Comotion::Data::Elasticsearch.new(@@type)
                user = es.read(params[:user_id])

                (user['_source']['wishlist'] ||= []) << params[:other_user_id]
                user['_source']['wishlist'].uniq
                es.update(user['_id'], {wishlist: user['_source']['wishlist']})

                user
              end

              # PUT    /users/:user_id/wishlist/:other_user_id { timestamp, location }
              desc 'indicate that a user has been met.'
              put do
                es   = Comotion::Data::Elasticsearch.new(@@type)
                user = es.read(params[:user_id])

                (user['_source']['wish_met'] ||= []) << params[:other_user_id]
                user['_source']['wish_met'].uniq
                es.update(user['_id'], {wish_met: user['_source']['wish_met']})

                user
              end

              # DELETE /users/:user_id/wishlist/:other_user_id
              desc 'remove a user from the wishlist'
              delete do
                es   = Comotion::Data::Elasticsearch.new(@@type)
                user = es.read(params[:user_id])

                (user['_source']['wishlist'].delete ||= []) << params[:other_user_id]
                user['_source']['wishlist'].uniq
                es.update(user['_id'], {wishlist: user['_source']['wishlist']})

                user
              end

            end # route_param :other_user_id
          end # namespace :wishlist

          namespace :connections do

            # GET /users/:user_id/connections { mode=*outgoing|incoming }
            desc 'get all connections optionally filtered by directionality'
            get do
            end

            # GET /users/:user_id/connections/recommended
            desc 'request a list of recommended connections'
            params do
              use :network
            end
            get :recommended do
              es = Comotion::Data::Elasticsearch.new(@@type)

              this_user = es.read(params[:user_id])
              interests = (this_user['_source']['tags'] ||= []).map{ |t| t.downcase unless t.nil? }

              esq       = Esquire::RecommendedUsers.new(interests)
              esq.size  = params[:count] unless params[:count].nil?
              result    = network_filter(this_user, params, es.search(esq.build))
              return result['hits']
            end

            route_param :other_user_id do

              params do
                requires :other_user_id, type: String
              end

              desc 'Get your match-level with this user'
              get do
                es = Comotion::Data::Elasticsearch.new(@@type)

                this_user = es.get(params[:user_id])
                interests = (this_user['_source']['tags'] ||= []).map { |t| t.downcase unless t.nil? }
                esq       = Esquire::UserMatch.new(params[:other_user_id], interests)

                result = es.search(esq.build)
                match  = result['hits']['hits'][0]

                {score: match['_score']}
              end

              params do
                use :network
              end
              get :network do
                es = Comotion::Data::Elasticsearch.new(@@type)

                in_user  = es.read(params[:user_id])
                out_user = es.read(params[:other_user_id])

                interests = (in_user['_source']['tags'] ||= []).map { |t| t.downcase }
                network   = (out_user['_source']['following'] ||= []).uniq
                esq       = Esquire::NetworkMatch.new(network, interests)

                result    = network_filter(in_user, params, es.search(esq.build))
                return result['hits']
              end

              # POST /users/:user_id/connections/:other_user_id
              desc 'follow a user'
              post do
                es = Comotion::Data::Elasticsearch.new(@@type)

                in_user  = es.read(params[:user_id])
                out_user = es.read(params[:other_user_id])

                (in_user['_source']['following'] ||= []) << out_user['_id']
                (out_user['_source']['followers'] ||= []) << in_user['_id']

                es.update(in_user['_id'], {following: in_user['_source']['following'].uniq})
                es.update(out_user['_id'], {followers: out_user['_source']['followers'].uniq})

                {followed: true}
              end

              # DELETE /users/:user_id/connections/:other_user_id
              desc 'unfollow a user'
              delete do
                es = Comotion::Data::Elasticsearch.new(@@type)

                in_user  = es.read(params[:user_id])
                out_user = es.read(params[:other_user_id])

                (in_user['_source']['following'] ||= []).delete(out_user['_id'])
                (out_user['_source']['followers'] ||= []).delete(in_user['_id'])

                es.update(in_user['_id'], {following: in_user['_source']['following'].uniq})
                es.update(out_user['_id'], {followers: out_user['_source']['followers'].uniq})

                {followed: false}
              end

            end # route_param :other_user_id
          end # namespace :connections

          namespace :events do

            # GET /user/:user_id/events/recommended
            desc 'Get a list of recommended events for this user. This should bias towards nearby events.'
            get :recommended do
            end

            # GET /user/:user_id/events/attending
            desc 'Get a list of events this user is or will be attending'
            get :attending do
            end

            desc 'Get the *next* future event this user will be attending'
            get :next do
              es   = Comotion::Data::Elasticsearch.new
              query = {
                size: 1,
                query: {match: {attending: params[:user_id]}},
                sort:  [{start_time: {order: 'asc'}}]
              }

              result = es.type('event').search(query)
              if (result['hits']['hits'].empty?)
                return { upcoming: nil }
              else
                return { upcoming: result['hits']['hits'][0] }
              end
            end

            # GET /user/:user_id/events/invited
            desc 'Get a list of events to which this user is invited'
            get :invited do
            end

          end # namespace :events

          namespace :groups do

            # GET /user/:user_id/groups
            desc 'Get a list of groups this user is a member of'
            get do
            end

            # GET /user/:user_id/groups/recommended
            desc 'Get a list of groups recommended for this user'
            get :recommended do
            end

          end # namespace :groups

        end # route_param :user_id
      end # namespace :users

    end # class API
  end # module Users
end # module Comotion
