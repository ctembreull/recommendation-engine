module Comotion
  module Users
    class API < Grape::API

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
          end
        end
      end

      namespace :users do

        # POST /users
        desc 'Create or replace a user'
        params do
          use :person
        end
        post do
          person = {}
          model  = Comotion::Data::Person::Model.new
          # TODO: Use Comotion::Data::Model as a validator source and validate
          #       and check the data in the params before adding to the person hash
          model.members.each do |field|
            person[field] = params[:person][field]
          end

          elastic  = Comotion::Data::Elasticsearch.new(false).client
          index    = 'comotion'
          type     = 'person'

          response = elastic.index index: index, type: type, id: person[:id], body: person
        end

        # GET /users
        # I cannot conceive of a use-case where we'd need to get all users at once.
        # User lists in our case are heavily context-dependent.
        desc 'Get all users - probably inadvisable'
        get do
          elastic  = Comotion::Data::Elasticsearch.new(false).client
          index    = 'comotion'
          type     = 'person'

          query = { query: { match_all: {} } }

          response = elastic.search index: index, type: type, body: query
        end

        route_param :user_id do

          params do
            requires :user_id, type: String
          end

          # GET /users/:user_id
          desc 'Retrive a user object by id'
          get do
          end

          # PUT /users/:user_id
          desc 'Modify an existing user object'
          put do
          end

          # PUT /users/:user_id/status
          desc 'Convenience endpoint for status update'
          params do
            requires :status, type: String, allow_blank: true
          end
          put :status do
            elastic = Comotion::Data::Elasticsearch.new(false).client
            index   = 'comotion'
            type    = 'person'

            response = elastic.update index: index, type: type, id: params[:user_id], body: {doc: { status: params[:status] }}
          end

          # DELETE /users/:user_id
          # This would be best if implemented as a two-step system. For now, for simplicity,
          # it's being represented as a fire-and-forget api call. Handle with extreme care.
          # Step 1: POST   /users/:user_id/delete_token
          # Step 2: DELETE /users/:user_id?delete_token=:delete_token
          desc 'Delete an existing user object'
          delete do
            elastic = Comotion::Data::Elasticsearch.new(false).client
            index   = 'comotion'
            type    = 'person'
            # expected response:
            # {
            #   "found": true,
            #   "_index": "comotion",
            #   "_type": "person",
            #   "_id": "79b16ba8-c624-4605-961c-07c5f4a99466",
            #   "_version": 2
            # }
            response = elastic.delete index: index, type: type, id: params[:user_id]
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
              end

              # PUT    /users/:user_id/wishlist/:other_user_id { timestamp, location }
              desc 'indicate that a user has been met.'
              put do
              end

              # DELETE /users/:user_id/wishlist/:other_user_id
              desc 'remove a user from the wishlist'
              delete do
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
              optional :role,  type: String
              optional :debug, type: Boolean
            end
            get :recommended do
              elastic = Comotion::Data::Elasticsearch.new(false).client
              index   = 'comotion'
              type    = 'person'

              this_user = elastic.get index: index, type: type, id: params[:user_id]
              esq       = Esquire::UserRecommendation.new
              esq.roles = params[:role].split(',') unless params[:role].nil?
              esq.interests = this_user['_source']['tags'].map { |t| t.downcase }

              results = Comotion::Data::Person::Formatter.from_elasticsearch(esq.run)

              if (params[:debug])
                return {query: esq.build, results: results}
              else
                return results
              end

            end

            route_param :other_user_id do

              params do
                requires :other_user_id, type: String
              end

              desc 'get other user with compatibility'
              get do
                elastic = Comotion::Data::Elasticsearch.new(false).client
                index   = 'comotion'
                type    = 'person'

                this_user = elastic.get index: index, type: type, id: params[:user_id]

              end

              # POST /users/:user_id/connections/:other_user_id
              desc 'follow a user'
              post do
              end

              # DELETE /users/:user_id/connections/:other_user_id
              desc 'unfollow a user'
              delete do
              end

            end # route_param :other_user_id
          end # namespace :connections

          namespace :events do

            # GET /user/:user_id/events/recommended
            desc 'Get a list of recommended events for this user'
            get :recommended do
            end

            # GET /user/:user_id/events/attending
            desc 'Get a list of events this user is or will be attending'
            get :attending do
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
