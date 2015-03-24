module Comotion
  module Users
    class API < Grape::API

      namespace :users do

        # POST /users
        desc 'Create or replace a user'
        post do
        end

        # GET /users
        # I cannot conceive of a use-case where we'd need to get all users at once.
        # User lists in our case are heavily context-dependent.
        desc 'Get all users - probably inadvisable'
        get do
          # TODO: Find an implementation for this or remove it
          # no-op
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
          put :status do
          end

          # DELETE /users/:user_id
          # This would be best if implemented as a two-step system. For now, for simplicity,
          # it's being represented as a fire-and-forget api call. Handle with extreme care.
          # Step 1: POST   /users/:user_id/delete_token
          # Step 2: DELETE /users/:user_id?delete_token=:delete_token
          desc 'Delete an existing user object'
          delete do
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
            get :recommended do
            end

            route_param :other_user_id do

              params do
                requires :other_user_id, type: String
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
