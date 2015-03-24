module Comotion
  module Groups
    class API < Grape::API

      namespace :groups do

        post do
        end

        get do
        end

        route_param :group_id do

          params do
            requires :group_id, type: String
          end

          get do
          end

          put do
          end

          delete do
          end

          namespace :invitations do

            post do
              # TODO: invite user(s) to this group
            end

            get do
            end

            route_param :invitation_id do

              params do
                requires :invitation_id, type: String
              end

              get do
                # TODO: details about invitation for current-user
              end

              post do
                # TODO: accept invitation for current-user
              end

              delete do
                # TODO: decline invitation for current-user
              end

            end # route_pram :invitation_id

          end # namespace :invitations

        end # route_param :group_id
      end # namespace :groups

    end # class API
  end # module Groups
end # module Comotion
