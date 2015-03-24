module Comotion
  module Events
    class API < Grape::API

      namespace :events do

        post do
        end

        get do
        end

        route_param :event_id do

          params do
            requires :event_id, type: String
          end

          get do
          end

          put do
          end

          delete do
          end

          namespace :attending do

            get do
              # TODO: all users who are attending this event
            end

            post do
              # TODO: current user intends to attend this event
            end

            delete do
              # TODO: current user no longer intends to attend this event
            end

          end # namespace :attending

          namespace :invitations do

            post do
              # TODO: send event invitations to a list of users
            end

            get do
            end

            route_param :invitation_id do

              params do
                requires :invitation_id, type: String
              end

              get do
              end

              post do
              end

              delete do
              end

            end # route_param :invitation_id
          end # namespace :invitations

        end # route_param :event_id
      end # namespace :events

    end # class API
  end # module Events
end # module Comotion
