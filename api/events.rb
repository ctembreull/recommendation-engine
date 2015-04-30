module Comotion
  module Events
    class API < Grape::API

      @@type = 'event'

      helpers do
        params :event do
          requires :event, type: Hash do
            requires :id,          type: Integer
            optional :uid,         type: String
            optional :categories,  type: Array
            optional :title,       type: String
            optional :description, type: String
            optional :avatar,      type: String
            optional :start_time,  type: String
            optional :end_time,    type: String
            optional :location,    type: String
            optional :tags,        type: Array

            optional :pin, type: Hash do
              optional :coords, type: String
              optional :color,  type: String
            end

          end
        end
      end

      namespace :events do

        params do
          use :event
        end
        post do
          event = {}
          model = Comotion::Data::Event::Model.new
          model.members.each do |field|
            if (field == :start_time or field == :end_time)
              unless params[:event][field].nil?
                dt = params[:event][field]
                dt += "-0800"
                date_obj = DateTime.parse(dt)
                event[field] = date_obj.utc.strftime('%Y-%m-%dT%H:%M:%S%z')
              end
            else
              event[field] = params[:event][field] unless params[:event][field].nil?
            end
          end

          es = Comotion::Data::Elasticsearch.new(@@type)
          response = es.create_or_update(event)

          return response
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
