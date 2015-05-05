module Comotion
  module Content
    class API < Grape::API
      @@type = 'content'

      helpers do
        params :content do
          requires :content, type: Hash do
            requires :id,         type: String
            optional :title,      type: String
            optional :content,    type: String
            optional :tags,       type: String
            optional :rating,     type: Integer
            optional :created_by, type: String
            optional :created_at, type: DateTime
          end
        end # params :content
      end # helpers

      namespace :content do
        # POST /content
        params do
          use :content
        end
        post do
          model   = Comotion::Data::Team::Model.new
          content = {}
          model.members.each { |f| content[f] = params[:content][f] unless params[:content][f].nil? }
          Comotion::Data::Elasticsearch.new(@@type).create_or_update(content)
        end

        route_param :content_id do
          params do
            requires :content_id, type: String
          end

          # GET /content/:content_id
          get do
            Comotion::Data::Elasticsearch.new(@@type).document(params[:content_id])
          end

          # PUT /content/:content_id/rating
          params do
            requires :rating, type: Integer
          end
          put :rating do
            Comotion::Data::Elasticsearch.new(@@type).update(params[:content_id], { rating: params[:rating] })
          end

          # TODO: DELETE /content/:content_id
          delete do
            Comotion::Data::Elasticsearch.new(@@type).delete(params[:content_id])
          end

        end # route_param :content_id
      end # namespace :content
    end # class API
  end # module Content
end # module Comotion
