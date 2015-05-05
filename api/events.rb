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

        # POST /events
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
        end

        route_param :event_id, type: String do

          # GET /events/#event_id
          get do
            response = Comotion::Data::Elasticsearch.new(@@type).document(params[:event_id])
          end

          # DELETE /events/:event_id
          delete do
            response = Comotion::Data::Elasticsearch.new(@@type).delete(params[:event_id])
          end

          namespace :attending do

            namespace :compatibility do
              route_param :user_id do
                params do
                  requires :user_id, type: String
                end

                get do
                  es = Comotion::Data::Elasticsearch.new(nil)
                  event = es.type('event').document(params[:event_id])
                  user  = es.type('person').document(params[:user_id])

                  interests = (user['_source']['tags'] ||= []).map { |t| t.downcase }
                  attending = (event['_source']['attending'] ||= [])
                  esq       = Esquire::NetworkMatch.new(attending, interests)

                  result    = network_filter(user, params, es.search(esq.build))
                end
              end # route_param :user_id
            end # namespace :compatibility

            # GET /events/:event_id/attending
            get do
              # TODO: all users who are attending this event
              event = Comotion::Data::Elasticsearch.new(@@type).document(params[:event_id])
              { attending: (event['_source']['attending'] ||= []) }
            end

            route_param :user_id, type: String do
              # GET /events/:event_id/attending/:user_id
              get do
                event = Comotion::Data::Elasticsearch.new(@@type).document(params[:event_id])
                {attending: event['_source']['attending'].include?(params[:user_id])}
              end

              # POST /events/:event_id/attending/:user_id
              post do
                es = Comotion::Data::Elasticsearch.new(@@type)

                event = es.document(params[:event_id])
                (event['_source']['attending'] ||= []) << params[:user_id]

                es.update(params[:event_id], {attending: event['_source']['attending'].uniq})

                {attending: true}
              end

              # DELETE /events/:event_id/attending/:user_id
              delete do
                # TODO: current user no longer intends to attend this event
                es = Comotion::Data::Elasticsearch.new(@@type)

                event = es.document(params[:event_id])
                (event['_source']['attending'] ||= []).delete(params[:user_id])

                es.update(params[:event_id], {attending: event['_source']['attending'].uniq})

                {attending: false}
              end
            end # route_param :user_id

          end # namespace :attending

        end # route_param :event_id
      end # namespace :events

    end # class API
  end # module Events
end # module Comotion
