module Comotion
  module Groups
    class API < Grape::API
      @@type = 'group'

      helpers do
        params :group do
          requires :group, type: Hash do
            requires :id,          type: String, allow_blank: false
            optional :name,        type: String
            optional :description, type: String
            optional :join_policy, type: Integer
            optional :created_at,  type: DateTime
            optional :website,     type: String
            optional :avatar,      type: String
            optional :url,         type: String
          end
        end
      end

      namespace :groups do

        params do
          use :group
        end
        post do
          group = {}
          model = Comotion::Data::Group::Model.new
          model.members.each do |field|
            group[field] = params[:group][field] unless params[:group][field].nil?
          end

          es = Comotion::Data::Elasticsearch.new('group')
          if es.exists(group[:id])
            response = es.update(group[:id], group)
          else
            response = es.index(group[:id], group)
          end

          return response
        end

        get do
        end

        route_param :group_id do
        end
      end # namespace :groups

    end # class API
  end # module Groups
end # module Comotion
