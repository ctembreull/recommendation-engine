module Comotion
  module Teams
    class API < Grape::API
      @@type = 'team'

      helpers do
        params :team do
          requires :team, type: Hash do
            requires :id,          type: String
            optional :name,        type: String
            optional :description, type: String
            optional :tags,        type: Array
            optional :members,     type: Array
            optional :seeking,     type: Array
            optional :avatar,      type: String
            optional :url,         type: String
          end # requires :team
        end # params :team
      end # helpers

      namespace :teams do
        # POST /teams
        params do
          use :team
        end
        post do
          model = Comotion::Data::Team::Model.new
          team  = {}
          model.members.each { |f| team[f] = params[:team][f] unless params[:team][f].nil? }
          Comotion::Data::Elasticsearch.new(@@type).create_or_update(team)
        end

        route_param :team_id do
          params do
            requires :team_id, type: String
          end

          # GET /teams/:team_id
          get do
            response = Comotion::Data::Elasticsearch.new(@@type).document(params[:team_id])
          end

          # DELETE /teams/:team_id
          delete do
            response = Comotion::Data::Elasticsearch.new(@@type).delete(params[:team_id])
          end

          namespace :members do
            # GET /teams/:team_id/members
            get do
              team = Comotion::Data::Elasticsearch.new(@@type).document(params[:team_id])
              { members: (team['_source']['members'] ||= []) }
            end

            namespace :compatibility do
              route_param :user_id do
                params do
                  requires :user_id, type: String
                end

                # TODO: GET /teams/:team_id/members/compatibility/:user_id
                get do
                  es   = Comotion::Data::Elasticsearch.new
                  team = es.type('team').document(params[:team_id])
                  user = es.type('person').document(params[:user_id])

                  interests = (user['_source']['tags'] ||= []).map { |t| t.downcase }
                  members   = (team['_source']['members'] ||= [])
                  esq       = Esquire::NetworkMatch.new(attending, interests)

                  result = network_filter(user, params, es.search(esq.build))
                  return result['hits']
                end
              end # route_param :user_id
            end # namespace :compatibility

            route_param :user_id do
              params do
                requires :user_id, type: String
              end

              # GET /teams/:team_id/members/:user_id
              get do
                team = Comotion::Data::Elasticsearch.new(@@type).document(params[:team_id])
                { member: ((team['_source']['members'] ||= []).include?(params[:user_id])) }
              end

              # POST /teams/:team_id/members/:user_id
              post do
                es   = Comotion::Data::Elasticsearch.new(@@type)
                team = es.document(params[:team_id])

                (team['_source']['members'] ||= []) << params[:user_id]
                es.update(params[:team_id], { members: team['_source']['members'].uniq })

                { member: true }
              end

              # TODO: DELETE /teams/:team_id/members/:user_id
              delete do
                es   = Comotion::Data::Elasticsearch.new(@@type)
                team = es.document(params[:team_id])

                (team['_source']['members'] ||= []).delete(params[:user_id])
                es.update(params[:team_id], {members: team['_source']['members'].uniq})

                { member: false }
              end

            end # route_param :user_id
          end # namespace :members
        end # route_param :team_id
      end # namespace :teams

    end # class API
  end # module Teams
end # module Comotion
