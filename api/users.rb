module Comotion
  module Users
    class API < Grape::API

      namespace :users do

        desc 'Create a user'
        params do
        end
        post do
        end

        desc 'Get all users - probably inadvisable'
        get do
          # TODO: Find an implementation for this or remove it
          # no-op
        end

        route_param :user_id do

          params do
            requires :user_id, type: String
          end

          desc 'Retrive a user object by id'
          get do
            
          end

          desc 'Modify an existing user object'
          params do
          end
          put do
          end

          desc 'Convenience endpoint for status update'
          params do
            requires :status, type: String
          end
          put :status do
          end

          desc 'Delete an existing user object'
          delete do
          end

          namespace :recommended do

            desc 'Get a list of other users that this user should follow/befriend'
            get :users do
            end

            desc 'Get a list of events that this user might be interested in'
            get :events do
            end

          end #namespace :recommended

          namespace :wishlist do
          end # namespace :wishlist

          namespace :connections do
          end # namespace :connections

          namespace :events do
          end # namespace :events

        end # route_param :user_id
      end # namespace :users

    end # class API
  end # module Users
end # module Comotion
